// Extend GenericCrafter for the Cryo-Silicon Crystallizer
// --- 1. DEFINE CUSTOM CRAFT EFFECT (Wave + Particle Burst) ---
const pressCraftEffect = new MultiEffect(
    // Expanding wave ring
    extend(WaveEffect, {
        colorFrom: Color.valueOf("bf92ff"),
        colorTo: Color.valueOf("bf92ff00"),
        sizeTo: 50,
        lifetime: 40,
        strokeFrom: 4,
        strokeTo: 0
    }),
    // Radial particle explosion
    extend(ParticleEffect, {
        particles: 25,
        length: 60,
        lifetime: 50,
        colorFrom: Color.valueOf("ffffff"),
        colorTo: Color.valueOf("a488ff")
    })
);

// --- 2. DEFINE UPDATE EFFECT (Radial Smoke Burst) ---
const pressUpdateEffect = extend(RadialEffect, {
    rotationSpacing: 45,
    amount: 8,
    length: 6,
    effect: Fx.smeltsmoke
});

// --- 3. CREATE THE TAU-MOLECULAR PRESS BLOCK ---
const tauMolecularPress = extend(GenericCrafter, "tau-molecular-press", {
    health: 50000,
    size: 4,
    category: Category.crafting,
    buildVisibility: BuildVisibility.shown,

    // Capacities & Timings
    hasPower: true,
    hasItems: true,
    hasLiquids: true,
    craftTime: 300, // 300 ticks = 5 seconds

    // Effects Configuration
    craftEffect: pressCraftEffect,
    updateEffect: pressUpdateEffect,
    updateEffectChance: 0.1,

    // Heat Requirement Configuration (120 Heat Units)
    hasHeat: true,
    heatRequirement: 120.0,

    // Dynamic Light Glow
    emitLight: true,
    lightColor: Color.valueOf("5a5ebc"),
    lightRadius: 60
});

// --- 4. DRAWER CONFIGURATION ---
tauMolecularPress.drawer = new DrawMulti(
    // Base block texture
    new DrawDefault(),

    // Pulsing core square shape (uses the specified indigo color)
    extend(DrawPulseShape, {
        square: true,
        color: Color.valueOf("5a5ebc")
    })
);

tauMolecularPress.requirements = ItemStack.with(
    hardenedCarbide, 1000,
    crystallineSilicon, 800,
    Items.surgeAlloy, 500,
    Items.thorium, 1000
);

// --- 6. CONSUMPTION CONFIGURATION ---
// Items: 10 Thorium + 2 Surge Alloy per cycle
tauMolecularPress.consumeItems(ItemStack.with(
    Items.thorium, 10,
    Items.surgeAlloy, 2
));

// Liquid: 0.4 Ionic Refrigerant per tick (24 units/sec)
const ionicRefrigerant = Vars.content.getByName(ContentType.liquid, "auraline-ionic-refrigerant") || Liquids.cryofluid;
tauMolecularPress.consumeLiquid(ionicRefrigerant, 0.4);

// Power: 45.0 power/sec (0.75 power/tick)
tauMolecularPress.consumePower(45.0 / 60.0);

// Heat: Require 120 units of heat to operate
tauMolecularPress.consume(new ConsumeHeatDynamic(120.0));

// --- 7. OUTPUT ITEM ---
const tauForgedThorium = Vars.content.getByName(ContentType.item, "auraline-tau-forged-thorium") || Items.thorium;
tauMolecularPress.outputItem = new ItemStack(tauForgedThorium, 5);

const cryoSiliconCrystallizer = extend(GenericCrafter, "cryo-silicon-crystallizer", {
    health: 14000,
    size: 3,
    category: Category.crafting,
    buildVisibility: BuildVisibility.shown,

    hasPower: true,
    hasItems: true,
    hasLiquids: true,
    craftTime: 60,
    itemCapacity: 30,
    liquidCapacity: 80,

    updateEffect: Fx.cool,
    updateEffectChance: 0.1,
    craftEffect: Fx.smelt,

    // Dynamic point light centered on the block when operating
    emitLight: true,
    lightColor: Color.valueOf("90e0ef"), // Cyan / Cryo glow
    lightRadius: 40
});

// --- DRAWER CONFIGURATION ---
// DrawMulti layers textures sequentially from back to front
cryoSiliconCrystallizer.drawer = new DrawMulti(
    // 1. Bottom base texture (e.g., cryo-silicon-crystallizer-bottom.png)
    new DrawRegion("-bottom"),

    // 2. Liquid layer that fills dynamically based on internal cryofluid levels
    new DrawLiquidTile(Liquids.cryofluid, 2.0), // 2.0 padding offset inside the block

    // 3. Main block outline / body frame (e.g., cryo-silicon-crystallizer.png)
    new DrawDefault(),

    // 4. Animated glowing center top light (pulses when actively crafting)
    new DrawFlame(Color.valueOf("90e0ef"))
);

// --- REQUIREMENTS & CONSUMPTION ---
cryoSiliconCrystallizer.requirements = ItemStack.with(
    Items.lead, 250,
    Items.titanium, 150,
    Items.silicon, 200,
    Items.graphite, 100
);

cryoSiliconCrystallizer.consumeItems(ItemStack.with(
    Items.silicon, 3,
    Items.titanium, 2,
    Items.metaglass, 1
));

cryoSiliconCrystallizer.consumeLiquid(Liquids.cryofluid, 0.2);
cryoSiliconCrystallizer.consumePower(9.0 / 60.0);

const crystallineSilicon = Vars.content.getByName(ContentType.item, "auraline-magna-mod-crystalline-silicon") || Items.silicon;
cryoSiliconCrystallizer.outputItem = new ItemStack(crystallineSilicon, 2);