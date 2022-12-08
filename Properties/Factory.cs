using System;
using System.Reflection;
using LiveSplit.Model;
using LiveSplit.UI.Components;
using LiveSplit.Sonic3Din2D;

[assembly: ComponentFactory(typeof(Sonic3Din2DFactory))]

namespace LiveSplit.Sonic3Din2D
{
    public class Sonic3Din2DFactory : IComponentFactory
    {
        public string ComponentName => "Sonic 3D in 2D - Autosplitter";
        public string Description => "Autosplitter";
        public ComponentCategory Category => ComponentCategory.Control;
        public string UpdateName => this.ComponentName;
        public string UpdateURL => "https://raw.githubusercontent.com/SonicSpeedrunning/Sonic3Din2DSplitter/main/";
        public Version Version => Assembly.GetExecutingAssembly().GetName().Version;
        public string XMLURL => this.UpdateURL + "Components/update.LiveSplit.Sonic3Din2D.xml";
        public IComponent Create(LiveSplitState state) => new Sonic3Din2DComponent(state);
    }
}
