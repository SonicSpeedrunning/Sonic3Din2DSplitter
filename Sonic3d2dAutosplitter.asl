state("Sonic3D2d 1.26rc") {}
state("Sonic3D2d 1.26") {}
state("Sonic3D2d 1.26b") {}

init
{

    vars.watchers = new MemoryWatcherList {
        new MemoryWatcher<ushort>( new DeepPointer(game.ProcessName + ".exe", 0x0009F5D8, 0, 0x268, 0x2C8 ) ) { Name = "splitidentifier", Enabled = true },
        new MemoryWatcher<ushort>( new DeepPointer(game.ProcessName + ".exe", 0x0009F5D8, 0, 0x268, 0x278 ) ) { Name = "gameclear", Enabled = true },
        new MemoryWatcher<uint>( new DeepPointer(game.ProcessName + ".exe", 0x0009F5D8, 4, 0x1AC, 0x2A4, 0x258, 0 ) ) { Name = "lives", Enabled = true },
        new MemoryWatcher<ushort>( new DeepPointer(game.ProcessName + ".exe", 0x0009F5D8, 0, 0x268, 0x288 ) ) { Name = "shield", Enabled = true },
        
    };
    vars.expectedlevel = 2;

    vars.setGameClear = (Action<byte>)((value) => {
        int offset = new DeepPointer(game.ProcessName + ".exe", 0x0009F5D8, 0, 0x268 ).Deref<int>(game) + 0x278 ;
        vars.DebugOutput(String.Format("Setting clear file at {0:X} to {1:X}", offset, value));
        game.WriteBytes( (IntPtr) offset, new byte[] { value }  );
        
    });
    vars.setNiceLives = (Action)(() => {
        int offset = new DeepPointer(game.ProcessName + ".exe", 0x0009F5D8, 4, 0x1AC, 0x2A4, 0x258 ).Deref<int>(game);
        uint value = 0xFFFFFFFF - 42069;
        byte[] bytes = BitConverter.GetBytes(value);
        vars.DebugOutput(String.Format("Setting lives at {0:X} to {1:X}", offset, value ));
        game.WriteBytes( (IntPtr) offset, bytes );
        
    });
    vars.setShield = (Action<byte>)((value) => {
        int offset = new DeepPointer(game.ProcessName + ".exe", 0x0009F5D8, 0, 0x268 ).Deref<int>(game) + 0x288 ;
        vars.DebugOutput(String.Format("Setting shield at {0:X} to {1:X}", offset, value));
        game.WriteBytes( (IntPtr) offset, new byte[] { value }  );
        
    });
    current.gamemode = 0;
}

update {
    vars.watchers.UpdateAll(game);

    if ( vars.watchers["splitidentifier"].Changed ) {
        if ( vars.watchers["splitidentifier"].Current == 19 || vars.watchers["splitidentifier"].Current == 20 ) {
            current.gamemode = vars.watchers["splitidentifier"].Current;
        }
    }
    if ( timer.CurrentPhase != TimerPhase.Running ) {
        if ( settings["upgradegameclear"] ) {
            if ( vars.watchers["gameclear"].Current != 3 && vars.watchers["splitidentifier"].Current == 20  ) {
                vars.setGameClear(0x03);
            }
            if ( vars.watchers["gameclear"].Current == 3 && vars.watchers["splitidentifier"].Current == 19  ) {
                vars.setGameClear(0x00);
            }
        }
        if ( settings["cheats"] ) {
            
            if ( settings["nicelives"] && vars.watchers["splitidentifier"].Current > 0 && vars.watchers["lives"].Current != ( 0xFFFFFFFF - 42069 ) ) {
                vars.setNiceLives();
            }
            if ( settings["shields"] ) {
                byte shield = 0;
                if ( current.gamemode == 20 ) {
                    if ( settings["shield_blue"]) {
                        shield = 1;
                    }
                    if ( settings["shield_fire"]) {
                        shield = 2;
                    }
                    if ( settings["shield_lightning"]) {
                        shield = 3;
                    }
                    if ( settings["shield_bubble"]) {
                        shield = 4;
                    }
                    if ( settings["shield_homing"]) {
                        shield = 5;
                    }
                }
                if ( vars.watchers["shield"].Current != shield ) {
                    vars.setShield(shield);
                }
            }
        }
    }

    if ( !vars.watchers["splitidentifier"].Changed ) {
        return false;
    }
    vars.DebugOutput(String.Format("splitidentifier: {0} was {1}", vars.watchers["splitidentifier"].Current, vars.watchers["splitidentifier"].Old));
}


start
{
    if ( vars.watchers["splitidentifier"].Current == 17 && vars.watchers["splitidentifier"].Old == 19 ) {
        vars.expectedlevel = 2;
        return true;
    }
}

reset
{
    if ( vars.watchers["splitidentifier"].Current == 19 ) {
        return true;
    }
}

split
{
    if ( vars.watchers["splitidentifier"].Current == vars.expectedlevel ) {
        vars.expectedlevel++;
        return true;
    }
    if ( vars.expectedlevel == 15 && vars.watchers["splitidentifier"].Current == 18 ) {
        // Game completed
        return true;
    }
}



startup
{
    string logfile = Directory.GetCurrentDirectory() + "\\S3D2DLogger.log";
    if ( File.Exists( logfile ) ) {
        File.Delete( logfile );
    }

    settings.Add("upgradegameclear", false, "Upgrade Game Clear (for Act 2 select)");
    settings.Add("cheats", false, "Cheats (Disable before doing runs)");
    settings.Add("nicelives", false, "Nice Lives", "cheats");
    settings.Add("shields", false, "Stage Load Shield (note: lowest will be chosen)", "cheats");
    settings.Add("shield_blue", false, "Basic Blue Shield", "shields");
    settings.Add("shield_fire", false, "Fire Shield", "shields");
    settings.Add("shield_lightning", false, "Lightning Shield", "shields");
    settings.Add("shield_bubble", false, "Bubble Shield", "shields");
    settings.Add("shield_homing", false, "Homing Shield", "shields");
    vars.DebugOutput = (Action<string>)((text) => {
        string time = System.DateTime.Now.ToString("dd/MM/yy hh:mm:ss:fff");
        File.AppendAllText(logfile, "[" + time + "]: " + text + "\r\n");
        print("[SEGA Master Splitter] "+text);
    });
}
