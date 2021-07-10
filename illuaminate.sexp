; -*- mode: Lisp;-*-

(sources
  src/
)

(at /
  (linters
    -syntax:string-index
    -format:separator-space
    -format:bracket-space
  )
  (lint
    (bracket-spaces
      (call no-space)
      (function-args no-space)
      (parens no-space)
      (table space)
      (index no-space)
    )

    (globals
      :max
      _CC_DEFAULT_SETTINGS
      _CC_DISABLE_LUA51_FEATURES
      sleep 
      write 
      printError 
      read 
      rs 
      SkyOS
      colors
      colours
      commands
      disk
      fs
      gps
      help
      http
      io
      keys
      multishell
      os 
      paintutils
      parallel
      peripheral
      pocket
      rednet
      redstone
      settings 
      shell
      term
      textutils
      turtle
      vector
      window
      _HOST
      LevelOS
      lOS
      lUtils
      PhileOS
      config
      periphemu
      ccemux
    )
  )
)
(at
  ;; Setup override for wip/old files
  (
    ;; Place non-linting files here
    wip/bios.lua
    wip/unbios.lua
    src/libraries/ec25519.lua ;; I'm not even going to touch this file, I'll probably break something.
  )
  (
    linters -all
  )
)