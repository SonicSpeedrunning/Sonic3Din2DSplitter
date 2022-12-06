state("Sonic3D2d 1.26rc") {}
state("Sonic3D2d 1.26") {}
state("Sonic3D2d 1.26b") {}
state("Sonic3D2d 1.27") {}
state("Sonic3D2d 1.28") {}
state("Sonic3D2d 1.29") {}
state("Sonic3D2d 1.30") {}

init
{
    const int SPLIT_INDENTIFIER   = 0x2C8,
        GAME_CLEAR          = 0x278,
        SHIELD              = 0x288,
        CHECKPOINT          = 0x048,
        CHECKPOINT_X        = 0x058,
        CHECKPOINT_Y        = 0x068;
    IntPtr ptr = IntPtr.Zero;
    Action checkptr = () => { if (ptr == IntPtr.Zero) throw new NullReferenceException(); };
    var scanner = new SignatureScanner(game, modules.First().BaseAddress, modules.First().ModuleMemorySize);


    ptr = scanner.Scan(new SigScanTarget(2, "8B 3D ???????? 8B 0C 87") { OnFound = (p, s, addr) => (IntPtr)p.ReadValue<int>(addr) });
    checkptr();
    vars.watchers = new MemoryWatcherList {
        new MemoryWatcher<ushort>(new DeepPointer(ptr, 0, 0x268, SPLIT_INDENTIFIER) ) { Name = "splitidentifier", Enabled = true },
        new MemoryWatcher<ushort>(new DeepPointer(ptr, 0, 0x268, GAME_CLEAR) ) { Name = "gameclear", Enabled = true },
        new MemoryWatcher<uint>(new DeepPointer(ptr, 4, 0x1AC, 0x2A4, 0x258, 0) ) { Name = "lives", Enabled = true },
        new MemoryWatcher<ushort>(new DeepPointer(ptr, 0, 0x268, SHIELD) ) { Name = "shield", Enabled = true },
        new MemoryWatcher<ushort>(new DeepPointer(ptr, 0, 0x268, CHECKPOINT) ) { Name = "checkpoint", Enabled = true },
        new MemoryWatcher<ushort>(new DeepPointer(ptr, 0, 0x268, CHECKPOINT_X) ) { Name = "checkpointX", Enabled = true },
        new MemoryWatcher<ushort>(new DeepPointer(ptr, 0, 0x268, CHECKPOINT_Y) ) { Name = "checkpointY", Enabled = true },
        
    };
    vars.expectedlevel = 2;

    vars.setGlobalVariable = (Action<int,int>)((variable, value) => {
        int offset = new DeepPointer(ptr, 0, 0x268).Deref<int>(game) + (int) variable;
        byte[] bytes = BitConverter.GetBytes(value);

        vars.DebugOutput(String.Format("Setting {0:X} at {1:X} to {2:X} ({3:X})",variable, offset, value, ptr));
        game.WriteBytes( (IntPtr) offset, bytes  );
        
    });

    vars.setGameClear = (Action<byte>)((value) => {
        vars.setGlobalVariable( GAME_CLEAR, value );
    });
    vars.setNiceLives = (Action)(() => {
        int offset = new DeepPointer(ptr, 4, 0x1AC, 0x2A4, 0x258).Deref<int>(game);
        uint value = 0xFFFFFFFF - 42069;
        byte[] bytes = BitConverter.GetBytes(value);
        vars.DebugOutput(String.Format("Setting lives at {0:X} to {1:X}", offset, value ));
        game.WriteBytes( (IntPtr) offset, bytes );
        
    });
    vars.setShield = (Action<byte>)((value) => {
        vars.setGlobalVariable( SHIELD, value );       
    });
    vars.setCheckpoint =  (Action)(() => {
        int checkpointx = 30;
        int checkpointy = 9999;
        int splitidentifier = vars.watchers["splitidentifier"].Current;

        if ( settings["dd1checkpoint"] && splitidentifier == 7 ) {
            checkpointx = 12200;
            checkpointy = 500;
        } else if ( settings["bosscheckpoint"] ) {

            switch ( splitidentifier ) {
                
                case 1: /* GG1 */
                    checkpointx = 9240;
                    checkpointy = 1102;
                    break;
                case 2: /* GG2 */
                    checkpointx = 9159;
                    checkpointy = 277;
                    break;
                case 3: /* RR1 */
                    checkpointx = 11093;
                    checkpointy = 931;
                    break;
                case 4: /* RR2 */
                    checkpointx = 6178;
                    checkpointy = 359;
                    break;
                case 5: /* SS1 */
                    checkpointx = 12260;
                    checkpointy = 642;
                    break;
                case 6: /* SS2 */
                    checkpointx = 12200;
                    checkpointy = 770;
                    break;
                case 7: /* DD1 */
                    checkpointx = 23863;
                    checkpointy = 634;
                    break;
                case 8: /* DD2 */
                    checkpointx = 7998;
                    checkpointy = 1930;
                    break;
                case 9: /* VV1 */
                    checkpointx = 8106;
                    checkpointy = 2562;
                    break;
                case 10: /* VV2 */
                    checkpointx = 5641;
                    checkpointy = 279;
                    break;
                case 11: /* GeGa1 */
                    checkpointx = 6528;
                    checkpointy = 994;
                    break;
                case 12: /* GeGa2 */
                    checkpointx = 6752;
                    checkpointy = 882;
                    break;
                case 13: /* PP1 */
                    checkpointx = 15952;
                    checkpointy = 498;
                    break;
                case 14: /* PP2 */
                    checkpointx = 16672;
                    checkpointy = 466;
                    break;
            }
        }
        
        if ( checkpointx > 0 && vars.watchers["checkpointX"].Current != checkpointx ) {
            vars.setGlobalVariable(CHECKPOINT_X, checkpointx);
        }
        if ( checkpointy > 0 && vars.watchers["checkpointY"].Current != checkpointy ) {
            vars.setGlobalVariable(CHECKPOINT_Y, checkpointy);
        }
        if ( vars.watchers["checkpointX"].Current > 0 && vars.watchers["checkpointY"].Current > 0 && vars.watchers["checkpoint"].Current != 1 ) {
            vars.setGlobalVariable(CHECKPOINT, 1);
        }
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
                if ( ( !settings["shield_onlyifnone"] && vars.watchers["shield"].Current != shield ) || ( settings["shield_onlyifnone"] && vars.watchers["shield"].Current == 0 ) ) {
                    vars.setShield(shield);
                }
            }
            if ( ( settings["bosscheckpoint"] || settings["dd1checkpoint"] ) && vars.watchers["splitidentifier"].Current > 0 ) {
                vars.setCheckpoint();
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
    settings.Add("shield_onlyifnone", false, "...only if No Shield", "shields");
    settings.Add("bosscheckpoint", false, "Activate Boss Checkpoint", "cheats");
    settings.Add("dd1checkpoint", false, "DD1 Jump Checkpoint", "cheats");
    vars.DebugOutput = (Action<string>)((text) => {
        string time = System.DateTime.Now.ToString("dd/MM/yy hh:mm:ss:fff");
        File.AppendAllText(logfile, "[" + time + "]: " + text + "\r\n");
        print("[S3D2D] "+text);
    });
}
