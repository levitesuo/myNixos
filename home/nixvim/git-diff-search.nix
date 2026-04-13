{ ... }:
{
  programs.nixvim.extraConfigLua = ''
    local function git_uncommitted_changes(opts)
      local ok, pickers = pcall(require, "telescope.pickers")
      if not ok then
        vim.notify("Telescope not available", vim.log.levels.ERROR)
        return
      end
      local finders = require("telescope.finders")
      local conf    = require("telescope.config").values

      opts = opts or {}
      local results = {}
      local seen    = {}

      local function parse_diff(cmd)
        local handle = io.popen(cmd .. " 2>/dev/null")
        if not handle then return end

        local current_file = nil
        local new_lnum     = 0

        for line in handle:lines() do
          -- New file being diffed
          local f = line:match("^%+%+%+ b/(.+)$")
          if f then current_file = f end

          -- Hunk header: @@ -old +new_start[,count] @@
          local hs = line:match("^@@ [^+]*%+(%d+)")
          if hs then new_lnum = tonumber(hs) - 1 end

          -- Added lines (skip the +++ file header lines)
          if current_file and line:sub(1, 1) == "+" and line:sub(1, 3) ~= "+++" then
            new_lnum = new_lnum + 1
            local key = current_file .. ":" .. new_lnum
            if not seen[key] then
              seen[key] = true
              local text = line:sub(2)
              table.insert(results, {
                filename = current_file,
                lnum     = new_lnum,
                col      = 0,
                text     = text,
                ordinal  = current_file .. " " .. text,
              })
            end
          end
        end
        handle:close()
      end

      -- Unstaged and staged changes separately to avoid duplicates via seen{}
      parse_diff("git diff -U0")
      parse_diff("git diff --cached -U0")

      if #results == 0 then
        vim.notify("No uncommitted changes", vim.log.levels.INFO)
        return
      end

      pickers.new(opts, {
        prompt_title = "Uncommitted Changes",
        finder = finders.new_table({
          results = results,
          entry_maker = function(entry)
            return {
              value    = entry.filename,
              display  = entry.filename .. ":" .. entry.lnum .. ": " .. entry.text,
              ordinal  = entry.ordinal,
              filename = entry.filename,
              lnum     = entry.lnum,
              col      = entry.col,
            }
          end,
        }),
        -- grep_previewer opens the file at the changed line with surrounding context
        previewer = conf.grep_previewer(opts),
        sorter    = conf.generic_sorter(opts),
      }):find()
    end

    vim.keymap.set("n", "<leader>gu", git_uncommitted_changes, { desc = "Uncommitted changes" })
  '';
}
