state("Sonic3D2d 1.26rc") {}
state("Sonic3D2d 1.26") {}

init
{

    vars.watchers = new MemoryWatcherList {
        new MemoryWatcher<ushort>( new DeepPointer(game.ProcessName + ".exe", 0x0009F5D8, 0, 0x268, 0x2C8 ) ) { Name = "splitidentifier", Enabled = true },
        new MemoryWatcher<ushort>( new DeepPointer(game.ProcessName + ".exe", 0x0009F5D8, 0, 0x268, 0x278 ) ) { Name = "gameclear", Enabled = true }
        
    };
    vars.expectedlevel = 2;
}

update {
    vars.watchers.UpdateAll(game);
    if ( settings["upgradegameclear"] && vars.watchers["gameclear"].Current != 3 ) {
        int offset = new DeepPointer(game.ProcessName + ".exe", 0x0009F5D8, 0, 0x268 ).Deref<int>(game) + 0x278 ;
        vars.DebugOutput(String.Format("Upgrading clear file {0:X}", offset));
        game.WriteBytes( (IntPtr) offset, new byte[] { 0x03 }  );
    }
    if ( !vars.watchers["splitidentifier"].Changed ) {
        return false;
    }
    vars.DebugOutput(String.Format("splitidentifier: {0} was {1}", vars.watchers["splitidentifier"].Current, vars.watchers["splitidentifier"].Old));
}


start
{
    if ( vars.watchers["splitidentifier"].Current == 17 ) {
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
    vars.DebugOutput = (Action<string>)((text) => {
        string time = System.DateTime.Now.ToString("dd/MM/yy hh:mm:ss:fff");
        File.AppendAllText(logfile, "[" + time + "]: " + text + "\r\n");
        print("[SEGA Master Splitter] "+text);
    });
}
