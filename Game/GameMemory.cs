using System;
using LiveSplit.ComponentUtil;

namespace LiveSplit.Sonic3Din2D
{
    partial class Watchers
    {
        // Base address
        private IntPtr baseAddress;

        // Fake Watchers
        public FakeMemoryWatcher<Acts> LevelID { get; protected set; }

        public Watchers()
        {
            LevelID = new FakeMemoryWatcher<Acts>(() => { short value = new DeepPointer(baseAddress, 0x0, 0x268, 0x2C8).Deref<short>(game); return (Acts)value != Acts.Undefined ? (Acts)value : LevelID.Current; });
        }

        public void Update()
        {
            LevelID.Update();
        }

        /// <summary>
        /// This function is essentially equivalent of the init descriptor in script-based autosplitters.
        /// Everything you want to be executed when the game gets hooked needs to be put here.
        /// The main purpose of this function is to perform sigscanning and get memory addresses and offsets
        /// needed by the autosplitter.
        /// </summary>
        private void GetAddresses()
        {
            baseAddress = new SignatureScanner(game, game.MainModuleWow64Safe().BaseAddress, game.MainModuleWow64Safe().ModuleMemorySize)
                .ScanOrThrow(new SigScanTarget(2, "8B 3D ???????? 8B 0C 87") { OnFound = (p, s, addr) => p.ReadPointer(addr) });
        }

        public bool SetNiceLives() => Init() ? game.WriteValue((IntPtr)new DeepPointer(baseAddress, 0x4, 0x1AC, 0x2A4, 0x258).Deref<int>(game), -1338) : false;

        public bool SetGameClear() => Init() ? game.WriteValue<short>((IntPtr)new DeepPointer(baseAddress, 0x0, 0x268).Deref<int>(game) + 0x278, 0x3) : false;

        public bool SetShield(byte shieldType) => Init() ? game.WriteValue<short>((IntPtr)new DeepPointer(baseAddress, 0x0, 0x268).Deref<int>(game) + 0x288, shieldType) : false;
    }

    enum Acts : int
    {
        Undefined = 0,
        GreenGroveAct1 = 1,
        GreenGroveAct2 = 2,
        RustyRuinAct1 = 3,
        RustyRuinAct2 = 4,
        SpringStadiumAct1 = 5,
        SpringStadiumAct2 = 6,
        DiamondDustAct1 = 7,
        DiamondDustAct2 = 8,
        VolcanoGalleryAct1 = 9,
        VolcanoGalleryAct2 = 10,
        GeneGadgetAct1 = 11,
        GeneGadgetAct2 = 12,
        PanicPuppetAct1 = 13,
        PanicPuppetAct2 = 14,
        FinalFight = 15,

        GameStart = 17,
        Ending = 18,
        NewGameMenu = 19,
        ContinueMenu = 20,
    }
}