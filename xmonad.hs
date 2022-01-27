import XMonad
import System.Exit
import System.IO

-- Layouts
import XMonad.Layout.Spacing
import XMonad.Layout.Spiral
import XMonad.Layout.Grid

-- Docks
import XMonad.Hooks.ManageDocks

-- Haskell
import Data.Monoid
import Data.Ratio

-- Logs
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))

-- Runtime
import XMonad.Util.SpawnOnce
import XMonad.Util.Run

-- Utils
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Graphics.X11.ExtraTypes.XF86 (xF86XK_AudioLowerVolume, xF86XK_AudioRaiseVolume, xF86XK_AudioMute)

myTerminal      = "alacritty"
myDmenuCmd      = "/home/gibran/.xmonad/dmenu_run.sh"
myBrowserCmd    = "tabbed -c vimb -e"

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myClickJustFocuses :: Bool
myClickJustFocuses = False

myBorderWidth   = 2

myModMask       = mod4Mask

myWorkspaces = [ "1", "2", "3", "4", "5", "6", "7", "8", "9" ]

myNormalBorderColor  = "#19212f"
myFocusedBorderColor = "#8ebd6b"

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm,               xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm,               xK_p     ), spawn myDmenuCmd)

    -- launch a web browser
    , ((modm,               xK_b     ), spawn myBrowserCmd)

    -- close focused window
    , ((modm,               xK_c     ), kill)

    -- sink the volume 
    , ((0, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ -2%")

    -- raise the volume
    , ((0, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ +2%")

    -- toggle the volume
    , ((0, xF86XK_AudioMute), spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm .|. shiftMask, xK_m), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))
    --
    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm .|. shiftMask, xK_c     ), spawn "xmonad --recompile; xmonad --restart")
    
    -- Shutdowm
    , ((modm .|. shiftMask, xK_s     ), spawn "shutdowm now")
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))
    ]

myLayout = avoidStruts (spacing 5 $ layoutTall ||| layoutSpiral ||| layoutGrid ||| layoutMirror ||| layoutFull)
    where
      layoutTall = Tall 1 (3/100) (1/2)
      layoutSpiral = spiral (125 % 146)
      layoutGrid = Grid
      layoutMirror = Mirror (Tall 1 (3/100) (3/5))
      layoutFull = Full
            
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

myEventHook = mempty

myStartupHook = do
  spawnOnce "nitrogen --restore"
  spawnOnce "picom -b -f"

main = do 
  h <- spawnPipe "xmobar ~/.xmonad/.xmobarrc.hs"
  xmonad $ docks def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = dynamicLogWithPP $ xmobarPP { 
                                                      ppOutput = hPutStrLn h 
                                                      -- Current workspace
                                                    , ppCurrent = xmobarColor "#8ebd6b" "" . wrap
                                                                  ("<box type=Bottom width=1 mt=1 color=#8ebd6b>") "</box>"
                                                      -- Visible but not current workspace
                                                    , ppVisible = xmobarColor "#dfdfdf" ""
                                                    , ppHidden = xmobarColor "#dfdfdf" "" . wrap
                                                                  ("<box type=Bottom width=1 mt=1 color=#dfdfdf>") "</box>"
                                                    , ppTitle = xmobarColor "#e2b86b" "" . shorten 20
                                                    , ppLayout = xmobarColor "#fa9b62" ""
                                                    , ppSep =  "<fc=#a0a0a0> | </fc>"
                                                    , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t] },
        startupHook        = myStartupHook
    }
