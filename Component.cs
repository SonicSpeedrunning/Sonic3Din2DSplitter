using System.Xml;
using System.Windows.Forms;
using LiveSplit.Model;
using LiveSplit.UI;
using LiveSplit.UI.Components;
using System;

namespace LiveSplit.Sonic3Din2D
{
    partial class Sonic3Din2DComponent : LogicComponent
    {
        public override string ComponentName => "Sonic 3D in 2D - Autosplitter";
        private readonly Settings settings = new Settings();
        private readonly Watchers watchers = new Watchers();
        private readonly TimerModel timer;

        public Sonic3Din2DComponent(LiveSplitState state)
        {
            timer = new TimerModel { CurrentState = state };

            settings.SetNiceLives += SetNiceLives;
            settings.SetGameClear += SetGameClear;
            settings.SetShield += SetShield;
        }

        private void SetNiceLives(object sender, EventArgs e) => watchers.SetNiceLives();
        private void SetGameClear(object sender, EventArgs e) => watchers.SetGameClear();
        private void SetShield(object sender, byte shieldType) => watchers.SetShield(shieldType);

        public override void Dispose()
        {
            settings.SetNiceLives -= SetNiceLives;
            settings.SetGameClear -= SetGameClear;
            settings.SetShield -= SetShield;
            settings.Dispose();
            watchers.Dispose();
        }

        public override XmlNode GetSettings(XmlDocument document) => this.settings.GetSettings(document);

        public override Control GetSettingsControl(LayoutMode mode) => this.settings;

        public override void SetSettings(XmlNode settings) => this.settings.SetSettings(settings);

        public override void Update(IInvalidator invalidator, LiveSplitState state, float width, float height, LayoutMode mode)
        {
            // If LiveSplit is not connected to the game, of course there's no point in going further
            if (!watchers.Init()) return;

            // Main update logic is inside the watcher class in order to avoid exposing unneded stuff to the outside
            watchers.Update();

            if (timer.CurrentState.CurrentPhase == TimerPhase.Running || timer.CurrentState.CurrentPhase == TimerPhase.Paused)
            {
                timer.CurrentState.IsGameTimePaused = IsLoading();
                if (GameTime() != null) timer.CurrentState.SetGameTime(GameTime());
                if (Reset()) timer.Reset();
                else if (Split()) timer.Split();
            }

            if (timer.CurrentState.CurrentPhase == TimerPhase.NotRunning)
            {
                if (Start()) timer.Start();
            }
        }
    }
}
