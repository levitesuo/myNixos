# Super+S opens a rofi list of Slack conversations and jumps straight into the
# selected one.
#
# The list is built by a background timer rather than on keypress: the Slack Web
# API needs several round trips (and one avatar download per person), which is
# far too slow to sit between a keystroke and a visible menu. The launcher only
# ever reads the cache, so the menu appears instantly and works offline.
{ config, pkgs, ... }:

let
  script = pkgs.writeScriptBin "slack-switcher" ''
    #!${pkgs.python3}/bin/python3
    """Cache Slack conversations (--refresh) or pick one and open it (no args)."""
    import hashlib, json, os, pathlib, subprocess, sys, time
    import urllib.error, urllib.parse, urllib.request

    TOKEN = os.environ.get("SLACK_TOKEN", "")
    DATA = pathlib.Path.home() / ".local/share/slack-switcher"
    CACHE = DATA / "channels.json"
    MRU = DATA / "mru.json"
    AVATARS = pathlib.Path.home() / ".cache/slack-switcher/avatars"

    # Matches the refresh timer. Pressing the bind on a cache older than this
    # kicks off a refresh in the background but still shows the stale list.
    STALE_AFTER = 3600

    # Resolved by the icon theme rather than being a path, so every channel row
    # carries the Slack mark while people rows carry a real face.
    CHANNEL_ICON = "slack"


    def api(method, **params):
        url = "https://slack.com/api/" + method
        if params:
            url += "?" + urllib.parse.urlencode(params)
        req = urllib.request.Request(url, headers={"Authorization": "Bearer " + TOKEN})

        # A workspace with many channels needs enough pages to reach Slack's
        # per-method rate limit, and one 429 would otherwise abandon the whole
        # refresh and leave the cache silently stale.
        for attempt in range(5):
            try:
                with urllib.request.urlopen(req, timeout=15) as r:
                    payload = json.loads(r.read())
                break
            except urllib.error.HTTPError as e:
                if e.code != 429 or attempt == 4:
                    raise
                time.sleep(int(e.headers.get("Retry-After", 5)) + 1)

        if not payload.get("ok"):
            raise RuntimeError(method + ": " + str(payload.get("error", "unknown error")))
        return payload


    def paged(method, key, **params):
        cursor = ""
        while True:
            page = api(method, cursor=cursor, limit=200, **params) if cursor \
                else api(method, limit=200, **params)
            for item in page.get(key, []):
                yield item
            cursor = (page.get("response_metadata") or {}).get("next_cursor", "")
            if not cursor:
                return


    def avatar(url):
        """Cache an avatar under a URL-derived name and return its path.

        Slack rewrites the URL whenever someone changes their picture, so keying
        on the URL means a new picture lands as a new file instead of being
        masked by a stale cache entry.
        """
        if not url:
            return None
        dest = AVATARS / (hashlib.sha256(url.encode()).hexdigest()[:16] + ".jpg")
        if dest.exists():
            return dest
        try:
            with urllib.request.urlopen(url, timeout=10) as r:
                data = r.read()
        except Exception:
            return None
        dest.write_bytes(data)
        return dest


    def refresh():
        if not TOKEN:
            print("slack-switcher: no SLACK_TOKEN, nothing to refresh", file=sys.stderr)
            return 0

        AVATARS.mkdir(parents=True, exist_ok=True)
        team_id = api("auth.test")["team_id"]
        entries = []

        for c in paged("conversations.list", "channels",
                       types="public_channel", exclude_archived="true"):
            entries.append({
                "id": c["id"],
                "label": "#" + c["name"],
                "icon": CHANNEL_ICON,
                "kind": "channel",
            })

        # users.info per DM partner rather than one users.list: the number of
        # open DMs is small, while the workspace directory is not, and there is
        # no reason to pull down people you never message.
        keep = set()
        for im in paged("users.conversations", "channels", types="im"):
            uid = im.get("user")
            if not uid:
                continue
            try:
                profile = api("users.info", user=uid)["user"]
            except Exception:
                continue
            name = (profile.get("profile", {}).get("display_name")
                    or profile.get("real_name")
                    or profile.get("name", uid))
            face = avatar(profile.get("profile", {}).get("image_48"))
            if face:
                keep.add(face.name)
            entries.append({
                "id": im["id"],
                "user": uid,
                "label": "@" + name,
                "icon": str(face) if face else CHANNEL_ICON,
                "kind": "im",
            })

        for stale in AVATARS.iterdir():
            if stale.name not in keep:
                stale.unlink(missing_ok=True)

        DATA.mkdir(parents=True, exist_ok=True)
        CACHE.write_text(json.dumps({
            "team_id": team_id,
            "fetched_at": int(time.time()),
            "entries": entries,
        }))
        print("slack-switcher: cached " + str(len(entries)) + " conversations")
        return 0


    def read_json(path, fallback):
        try:
            return json.loads(path.read_text())
        except Exception:
            return fallback


    def notify(body):
        subprocess.run(["${pkgs.libnotify}/bin/notify-send", "-a", "Slack", "Slack switcher", body])


    def order(entries, mru):
        """Anything you have opened before, most recent first; then the rest.

        Slack's API exposes no last-message timestamp on any list call, so this
        ranks by your own jump history instead — which is the recency that
        actually matters once the list has been used for a few days.
        """
        def key(e):
            last = mru.get(e["id"])
            if last is not None:
                return (0, -last, "")
            return (1 if e["kind"] == "im" else 2, 0, e["label"].lower())
        return sorted(entries, key=key)


    def launch():
        cache = read_json(CACHE, None)
        if not cache or not cache.get("entries"):
            notify("No cached conversations yet. Run: slack-switcher --refresh")
            return 1

        if time.time() - cache.get("fetched_at", 0) > STALE_AFTER:
            subprocess.Popen(
                ["${pkgs.systemd}/bin/systemctl", "--user", "start", "--no-block",
                 "slack-switcher-refresh.service"],
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
            )

        mru = read_json(MRU, {})
        entries = order(cache["entries"], mru)

        # rofi's dmenu icon protocol: "<text>\0icon\x1f<name-or-path>" per row.
        rows = "\n".join(e["label"] + "\0icon\x1f" + e["icon"] for e in entries)

        picked = subprocess.run(
            ["${config.programs.rofi.package}/bin/rofi",
             "-dmenu", "-i", "-p", "Slack",
             # Index rather than text: labels are user-controlled and need not
             # round-trip back to an id.
             "-format", "i",
             "-no-custom",
             # Keep the recency order intact while filtering, instead of letting
             # rofi re-rank matches by fuzzy score.
             "-no-sort",
             "-show-icons",
             "-theme-str", 'entry { placeholder: "Search Slack..."; }'],
            input=rows, capture_output=True, text=True,
        )
        if picked.returncode != 0 or not picked.stdout.strip():
            return 0
        try:
            entry = entries[int(picked.stdout.strip())]
        except (ValueError, IndexError):
            return 1

        mru[entry["id"]] = int(time.time())
        live = set(e["id"] for e in cache["entries"])
        MRU.parent.mkdir(parents=True, exist_ok=True)
        MRU.write_text(json.dumps({k: v for k, v in mru.items() if k in live}))

        url = "slack://channel?" + urllib.parse.urlencode({
            "team": cache["team_id"], "id": entry["id"],
        })
        # Through xdg-open, not a store path: the Slack on PATH is wrapped with
        # --ozone-platform=x11 for the iGPU, and an unwrapped pkgs.slack would
        # start a second, differently-flagged instance.
        subprocess.run(["${pkgs.xdg-utils}/bin/xdg-open", url])
        # The deep link does not reliably raise the window under Hyprland.
        # hyprctl comes from PATH so it always matches the running compositor.
        subprocess.run(["hyprctl", "dispatch", "focuswindow", "class:Slack"],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return 0


    if __name__ == "__main__":
        if "--refresh" in sys.argv[1:]:
            sys.exit(refresh())
        sys.exit(launch())
  '';
in
{
  home.packages = [ script ];

  services.onepassword-secrets.envFiles.slack.SLACK_TOKEN =
    "op://Private/Slack switcher/credential";

  systemd.user.services.slack-switcher-refresh = {
    Unit = {
      Description = "Cache Slack conversations for the rofi switcher";
      # Ordered after the secret render but deliberately not pulling it in, for
      # the same reason as linear-notify: this runs from a timer, and a Wants=
      # would re-activate a failed render on every tick.
      After = [ "graphical-session.target" "op-secrets.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${script}/bin/slack-switcher --refresh";
      # Both optional, later wins: the token normally comes from 1Password, but
      # a hand-written ~/.config/slack/credentials holding SLACK_TOKEN=xoxp-xxx
      # still works. With neither, the refresh exits without touching the cache.
      EnvironmentFile = [
        "-%h/.config/slack/credentials"
        "-%t/op-secrets/slack.env"
      ];
    };
  };

  systemd.user.timers.slack-switcher-refresh = {
    Unit.Description = "Refresh the Slack conversation cache hourly";
    Timer = {
      OnStartupSec = "1m";
      OnUnitActiveSec = "1h";
      Unit = "slack-switcher-refresh.service";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
