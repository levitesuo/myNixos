{ config, lib, pkgs, ...}:
{
    programs.git = {
        userName = "leevisuo";
        userEmail = "leevi.suotula@gmail.com";
        aliases = {
            # Simple aliases
            ga = "add";
            co = "checkout";
            
            # The '!' tells git to run this as a shell command
            # 'f() { ... }; f' is a standard pattern for git aliases with arguments
            gc = "!f() { git commit -m \"$*\"; }; f";
            
            # Pull then Push
            gp = "!git pull && git push";
            gs = "status";
            };
    };
}
