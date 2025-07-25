/*
 * #19 Scorpio's fight dialog doesn't disappear
 *
 * The hero is given a new guild and the Kapitel is adjusted and the condition function of the dialog is called.
 *
 * Expected behavior: The condition function will return FALSE.
 */
func int G1CP_Test_0019() {
    const int GIL_NONE = 0; GIL_NONE = G1CP_Testsuite_GetIntConst("GIL_NONE", 0);
    var int funcId; funcId = G1CP_Testsuite_CheckDialogConditionFunc("DIA_Scorpio_REFUSETRAIN_Condition");
    var int infoId; infoId = G1CP_Testsuite_CheckInfo("DIA_Scorpio_Hello");
    var int chptrId; chptrId = G1CP_Testsuite_CheckIntVar("Kapitel", 0);
    G1CP_Testsuite_CheckPassed();

    // Backup values
    var int chapterBak; chapterBak = G1CP_GetIntVarI(chptrId, 0, 0);
    var int guildBak; guildBak = Npc_GetTrueGuild(hero);
    var int toldBak; toldBak = Npc_KnowsInfo(hero, infoId);

    // Set new values
    G1CP_SetIntVarI(chptrId, 0, 4);
    Npc_SetTrueGuild(hero, GIL_NONE);
    G1CP_SetInfoToldI(infoId, TRUE);

    // Call dialog condition function
    G1CP_Testsuite_Call(funcId, 0, 0, FALSE);
    var int ret; ret = MEM_PopIntResult();

    // Restore values
    G1CP_SetIntVarI(chptrId, 0, chapterBak);
    Npc_SetTrueGuild(hero, guildBak);
    G1CP_SetInfoToldI(infoId, toldBak);

    // Check return value
    if (ret) {
        G1CP_TestsuiteErrorDetail("Dialog condition failed");
        return FALSE;
    } else {
        return TRUE;
    };
};
