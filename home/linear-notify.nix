{ pkgs, ... }:

let
  script = pkgs.writeTextFile {
    name = "linear-notify";
    executable = true;
    text = ''
      #!${pkgs.python3}/bin/python3
      import json, os, pathlib, subprocess, urllib.request

      API_KEY = os.environ.get("LINEAR_API_KEY", "")
      STATE_FILE = pathlib.Path.home() / ".local/share/linear-notify/seen.json"

      QUERY = """
      query {
        notifications(first: 20, filter: { readAt: { null: true } }) {
          nodes {
            id
            createdAt
            ... on IssueNotification {
              type
              issue { title identifier }
            }
            ... on ProjectNotification {
              type
              project { name }
            }
          }
        }
      }
      """

      def fetch():
          body = json.dumps({"query": QUERY}).encode()
          req = urllib.request.Request(
              "https://api.linear.app/graphql",
              data=body,
              headers={"Content-Type": "application/json", "Authorization": API_KEY},
          )
          with urllib.request.urlopen(req, timeout=10) as r:
              return json.loads(r.read())["data"]["notifications"]["nodes"]

      def load_seen():
          return set(json.loads(STATE_FILE.read_text())) if STATE_FILE.exists() else set()

      def save_seen(seen):
          STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
          STATE_FILE.write_text(json.dumps(list(seen)))

      def notify(summary, body):
          subprocess.run(["${pkgs.libnotify}/bin/notify-send", "-a", "Linear", summary, body])

      def main():
          if not API_KEY:
              return
          try:
              notifications = fetch()
          except Exception as e:
              print(f"linear-notify: {e}")
              return

          seen = load_seen()
          new_seen = set(seen)

          for n in reversed(notifications):
              nid = n["id"]
              if nid in seen:
                  continue
              ntype = n.get("type", "")
              issue = n.get("issue")
              project = n.get("project")
              if issue:
                  summary = f"{issue['identifier']}: {ntype.replace('Issue', "").strip().lower()}"
                  body = issue["title"]
              elif project:
                  summary = f"Linear: {ntype}"
                  body = project["name"]
              else:
                  summary = "Linear notification"
                  body = ntype
              notify(summary, body)
              new_seen.add(nid)

          save_seen(new_seen)

      main()
    '';
  };
in
{
  systemd.user.services.linear-notify = {
    Unit = {
      Description = "Linear notification poller";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${script}";
      # Create ~/.config/linear/credentials with: LINEAR_API_KEY=lin_api_xxxxx
      EnvironmentFile = "%h/.config/linear/credentials";
    };
  };

  systemd.user.timers.linear-notify = {
    Unit.Description = "Poll Linear for notifications every 30s";
    Timer = {
      OnStartupSec = "15s";
      OnUnitActiveSec = "30s";
      Unit = "linear-notify.service";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
