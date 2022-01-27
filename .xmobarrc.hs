Config { font            = "xft:Sauce Code Pro Nerd Font:pixelsize=15:antialias=true:hinting=true"
       , additionalFonts = [ "xft:Font Awesome 5 Free Solid:pixelsize=12"
                           , "xft:Font Awesome 5 Brands:pixelsize=12"
                           ]
       , bgColor      = "#19212f"
       , fgColor      = "#dfdfdf"
       , position       = TopSize L 100 24
       , lowerOnStart = True
       , hideOnStart  = False
       , allDesktops  = True
       , persistent   = True
       , iconRoot     = "."  -- default: "."
       , commands = [
                        -- Echos a "penguin" icon in front of the kernel output.
                      Run Com "echo" ["<fc=#1793d1><fn=3>\xf303 </fn></fc>"] "penguin" 3600
                        -- Echos the kernel version
                    , Run Com "uname" ["-srm"] "kernel" 3600
                        -- Echos the haskell logo
                    , Run Com "echo" ["<fc=#bf68d9><fn=3>\xe61f </fn></fc>"] "haskell" 3600
                        -- Get the cpu usage
                    , Run Cpu ["-t", "<fc=#48b0bd><fn=3>\xe706</fn></fc> cpu: (<fc=#48b0bd><total>%</fc>)","-H","50","--high","red"] 20
                        -- Get the memory   
                    , Run Memory ["-t", "<fc=#4fa6ed><fn=3>\xf85a </fn></fc> mem: <used>M (<fc=#4fa6ed><usedratio>%</fc>)"] 20
                        -- Ram used number and percent
                    , Run BatteryP ["BAT0"] ["-t", "<fc=#bf68d9><fn=3>\xf578</fn></fc> BAT0 : (<fc=#bf68d9><left>%</fc>)"] 360
                        -- Time and date
                    , Run Date "<fc=#8ebd6b><fc=#dfdfdf><fn=3>\xf650 </fn></fc>%b %d %Y - <fc=#dfdfdf><fn=3>\xf017 </fn></fc>(%H:%M)</fc> " "date" 50
                        -- Script that dynamically adjusts xmobar padding depending on number of trayer icons.
                    , Run StdinReader
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = " %haskell%<fc=#a0a0a0>|</fc> %StdinReader% } %date% { %penguin% %kernel% <fc=#a0a0a0>|</fc> %memory% <fc=#a0a0a0>|</fc> %cpu% <fc=#a0a0a0>|</fc> %battery%  " }
