/*
 * #16 Thorus' bribe dialog doesn't disappear
 *
 * The AI variable Grd_212_Torwache.aivar[AIV_PASSGATE] is set to TRUE and the condition functions of both dialogs are
 * called for each of them.
 *
 * Expected behavior: The condition functions will return FALSE.
 */
func int G1CP_Test_016_RunDialog(var string dialogConditionName, var string infoName) {
    var C_Npc npc; npc = G1CP_Testsuite_FindNpc("Grd_212_Torwache");
    var int funcId; funcId = G1CP_Testsuite_CheckDialogConditionFunc(dialogConditionName);
    var int infoId; infoId = G1CP_Testsuite_CheckInfo(infoName);
    var int aiVarId; aiVarId = G1CP_Testsuite_CheckIntConst("AIV_PASSGATE", 0);
    G1CP_Testsuite_CheckPassed();

    // Backup values
    var int aiVarBak; aiVarBak = G1CP_NpcGetAIVarI(npc, aiVarId, 0);
    var int toldBak; toldBak = Npc_KnowsInfo(hero, infoId);
    var C_Npc slfBak; slfBak = MEM_CpyInst(self);
    var C_Npc othBak; othBak = MEM_CpyInst(other);

    // Set new values
    G1CP_NpcSetAIVarI(npc, aiVarId, TRUE);
    G1CP_SetInfoTold(infoName, TRUE);
    self = MEM_CpyInst(hero);
    other = MEM_CpyInst(hero);

    // Call dialog condition function
    MEM_CallByID(funcId);
    var int ret; ret = MEM_PopIntResult();

    // Restore values
    self = MEM_CpyInst(slfBak);
    other = MEM_CpyInst(othBak);
    G1CP_NpcSetAIVarI(npc, aiVarId, aiVarBak);
    G1CP_SetInfoTold(infoName, toldBak);

    // Check return value
    if (ret) {
        G1CP_TestsuiteErrorDetailSSS("Dialog condition '", dialogConditionName, "' failed");
        return FALSE;
    };

    return TRUE;
};
func int G1CP_Test_016() {
    var int passed; passed = FALSE;

    // First dialog
    passed += G1CP_Test_016_RunDialog("Info_Thorus_Give1000Ore_Condition", "Info_Thorus_BribeGuard");
    passed += G1CP_Test_016_RunDialog("Info_Thorus_LetterForMages_Condition", "Info_Thorus_EnterCastle");

    return (passed == 2);
};
