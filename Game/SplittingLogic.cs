using System;

namespace LiveSplit.Sonic3Din2D
{
    partial class Sonic3Din2DComponent
    {
        private bool Start()
        {
            return settings.Start && watchers.LevelID.Old == Acts.NewGameMenu && watchers.LevelID.Current == Acts.GameStart;
        }

        private bool Split()
        {
            return
                (settings["c" + (int)watchers.LevelID.Old] && watchers.LevelID.Current == watchers.LevelID.Old + 1)
                || (settings.c14 && watchers.LevelID.Old == Acts.PanicPuppetAct2 && watchers.LevelID.Current == Acts.Ending)
                || (settings.c15 && watchers.LevelID.Old == Acts.FinalFight && watchers.LevelID.Current == Acts.Ending);
        }

        bool Reset()
        {
            return settings.Reset && watchers.LevelID.Current == Acts.NewGameMenu && watchers.LevelID.Changed;
        }

        bool IsLoading()
        {
            return false;
        }

        private TimeSpan? GameTime()
        {
            return null;
        }
    }
}