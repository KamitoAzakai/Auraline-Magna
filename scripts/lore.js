// Variable to track quest completion state within the session
let milestoneCompleted = false;

// 1. Define the Lore Dialogs
const introDialog = new BaseDialog("[#a1f1f7]Lore Objective: Crystalline Alignment[]");
introDialog.cont.add("[#a1f1f7]=== MISSION OBJECTIVE ===[]").row();
introDialog.cont.image().color(Color.valueOf("a1f1f7")).fillX().height(2).pad(10).row();
introDialog.cont.add(
    "To advance your technological capabilities, you must stabilize raw silicon into a refined crystalline lattice.\n\n" +
    "[lightgray]Construct a [white]Cryo-Silicon Crystallizer[] and provide it with [white]Silicon, Titanium, Metaglass,[] and [white]Cryofluid[] to produce your first batch of [a1f1f7]Crystalline Silicon[]."
).width(450).wrap().pad(10).row();
introDialog.addCloseButton();

const completionDialog = new BaseDialog("[#a1f1f7]Lore Milestone Achieved![]");
completionDialog.cont.add("[#a1f1f7]=== MATERIAL ACQUIRED ===[]").row();
completionDialog.cont.image().color(Color.valueOf("a1f1f7")).fillX().height(2).pad(10).row();
completionDialog.cont.add(
    "[white]Crystalline Silicon successfully synthesized![]\n\n" +
    "[lightgray]The perfectly aligned atomic structure holds extreme thermal and gravitational stability. Your foundation for advanced Auraline manufacturing is secured."
).width(450).wrap().pad(10).row();
completionDialog.addCloseButton();

// 2. Trigger Intro Dialog when the Client Loads
Events.on(ClientLoadEvent, () => {
    // Shows the intro prompt after client finishes loading
    Time.runTask(60, () => {
        introDialog.show();
    });
});

// 3. Monitor Item Pickup / Production for the Crystalline Silicon milestone
Events.on(PickupEvent, event => {
    checkCrystallineSilicon();
});

// Alternative trigger: Check core inventory updates during gameplay loop
Events.on(Trigger.update, () => {
    if (milestoneCompleted || Vars.state.isMenu()) return;

    // Check if the player's team core contains Crystalline Silicon
    const crystallineSilicon = Vars.content.getByName(ContentType.item, "auraline-crystalline-silicon") || Items.silicon;
    const core = Vars.player.team().core();

    if (core && core.items.get(crystallineSilicon) > 0) {
        milestoneCompleted = true;

        // Display toast on HUD
        Vars.ui.hudfrag.showToast("[#a1f1f7]Lore Milestone Complete: Crystalline Silicon Acquired![]");

        // Show completion story dialog
        completionDialog.show();
    }
});

function checkCrystallineSilicon() {
    if (milestoneCompleted) return;
    const crystallineSilicon = Vars.content.getByName(ContentType.item, "auraline-crystalline-silicon") || Items.silicon;

    if (Vars.player.team().core() && Vars.player.team().core().items.get(crystallineSilicon) > 0) {
        milestoneCompleted = true;
        Vars.ui.hudfrag.showToast("[#a1f1f7]Lore Milestone Complete: Crystalline Silicon Acquired![]");
        completionDialog.show();
    }
}