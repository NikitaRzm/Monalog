{-# LANGUAGE CPP #-}

module Vty where

import Graphics.Vty qualified as Vty
#if defined(mingw32_HOST_OS) || defined(__MINGW32__)
import Graphics.Vty.Platform.Windows qualified as Vty
import Graphics.Vty.Platform.Windows.Settings qualified as Vty
#else
import Graphics.Vty.Platform.Unix qualified as Vty
import Graphics.Vty.Platform.Unix.Settings qualified as Vty
import System.Posix.IO (handleToFd)
#endif
import System.IO

{- FOURMOLU_DISABLE -}
withVty :: (Vty.Vty -> IO a) -> IO a
withVty action = do
#if defined(mingw32_HOST_OS) || defined(__MINGW32__)
  -- https://github.com/microsoft/terminal/issues/16868
  withFile "\\\\.\\CONIN$" ReadWriteMode \tty -> do
#else
  withFile "/dev/tty" ReadWriteMode \ttyHandle -> do
    tty <- handleToFd ttyHandle
#endif
    defSettings <- Vty.defaultSettings
    vty <- Vty.mkVtyWithSettings Vty.defaultConfig defSettings{Vty.settingInputFd = tty, Vty.settingOutputFd = tty}
    action vty
