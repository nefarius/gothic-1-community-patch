/*
 * #18 Bloodwyn doesn't recognize the player's camp membership
 */
func int G1CP_0018_BloodwynProtectionMoney() {
    if (G1CP_IsFunc("Info_Bloodwyn_Hello_Condition", "int|none")) {
        HookDaedalusFuncS("Info_Bloodwyn_Hello_Condition", "G1CP_0018_BloodwynProtectionMoney_Hook");
        return TRUE;
    } else {
        return FALSE;
    };
};

/*
 * This function intercepts the dialog condition to introduce more conditions
 */
func int G1CP_0018_BloodwynProtectionMoney_Hook() {
    G1CP_ReportFuncToSpy();

    // Add the new condition (other conditions remain untouched)
    if (Npc_GetTrueGuild(hero)) {
        return FALSE;
    };

    // Continue with the original function
    ContinueCall();
};
