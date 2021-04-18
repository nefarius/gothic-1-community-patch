/*
 * Check if running automatic test
 */
func void G1CP_Testsuite_CheckManual() {
    // Do not move this code
    if (FALSE) {
        // This emulates the end of the caller function and forces it to return false
        FALSE;
        return;
    };

    // Check if manual tests are currently allowed
    if (!G1CP_TestsuiteAllowManual) {
        // Return into the if-block above as if it was the caller function
        MEM_SetCallerStackPos(MEM_GetFuncOffset(G1CP_Testsuite_CheckManual)+10); // 5 push + 5 jumpf
    };
};

/*
 * Check status of test and abort if it does not pass
 */
func void G1CP_Testsuite_CheckPassed() {
    // Do not move this code
    if (FALSE) {
        // This emulates the end of the caller function and forces it to return false
        FALSE;
        return;
    };

    // Check test status
    if (!G1CP_TestsuiteStatusPassed) {
        // Return into the if-block above as if it was the caller function
        MEM_SetCallerStackPos(MEM_GetFuncOffset(G1CP_Testsuite_CheckPassed)+10); // 5 push + 5 jumpf
    };
};

/*
 * Check if integer variable exists
 */
func int G1CP_Testsuite_CheckIntVar(var string name, var int arrIdx) {
    if (!G1CP_IsIntVar(name, arrIdx)) {
        if (arrIdx > 0) {
            name = ConcatStrings(ConcatStrings(ConcatStrings(name, "["), IntToString(arrIdx)), "]");
        };
        G1CP_TestsuiteErrorDetailSSS("Integer variable '", name, "' not found");
        G1CP_TestsuiteStatusPassed = FALSE;
        return -1;
    };
    return MEM_GetSymbolIndex(name);
};

/*
 * Check if integer constant exists
 */
func int G1CP_Testsuite_CheckIntConst(var string name, var int arrIdx) {
    if (!G1CP_IsIntConst(name, arrIdx)) {
        if (arrIdx > 0) {
            name = ConcatStrings(ConcatStrings(ConcatStrings(name, "["), IntToString(arrIdx)), "]");
        };
        G1CP_TestsuiteErrorDetailSSS("Integer constant '", name, "' not found");
        G1CP_TestsuiteStatusPassed = FALSE;
        return -1;
    };
    return MEM_GetSymbolIndex(name);
};

/*
 * Check if string variable exists
 */
func int G1CP_Testsuite_CheckStringVar(var string name, var int arrIdx) {
    if (!G1CP_IsStringVar(name, arrIdx)) {
        if (arrIdx > 0) {
            name = ConcatStrings(ConcatStrings(ConcatStrings(name, "["), IntToString(arrIdx)), "]");
        };
        G1CP_TestsuiteErrorDetailSSS("String variable '", name, "' not found");
        G1CP_TestsuiteStatusPassed = FALSE;
        return -1;
    };
    return MEM_GetSymbolIndex(name);
};

/*
 * Check if string constant exists
 */
func int G1CP_Testsuite_CheckStringConst(var string name, var int arrIdx) {
    if (!G1CP_IsStringConst(name, arrIdx)) {
        if (arrIdx > 0) {
            name = ConcatStrings(ConcatStrings(ConcatStrings(name, "["), IntToString(arrIdx)), "]");
        };
        G1CP_TestsuiteErrorDetailSSS("String constant '", name, "' not found");
        G1CP_TestsuiteStatusPassed = FALSE;
        return -1;
    };
    return MEM_GetSymbolIndex(name);
};

/*
 * Check if info instance exists
 */
func int G1CP_Testsuite_CheckInfo(var string name) {
    if (!G1CP_IsInfoInst(name)) {
        G1CP_TestsuiteErrorDetailSSS("Info instance '", name, "' not found");
        G1CP_TestsuiteStatusPassed = FALSE;
        return -1;
    };
    return MEM_GetSymbolIndex(name);
};

/*
 * Check if item instance exists
 */
func int G1CP_Testsuite_CheckItem(var string name) {
    if (!G1CP_IsItemInst(name)) {
        G1CP_TestsuiteErrorDetailSSS("Item instance '", name, "' not found");
        G1CP_TestsuiteStatusPassed = FALSE;
        return -1;
    };
    return MEM_GetSymbolIndex(name);
};

/*
 * Check if NPC instance exists
 */
func int G1CP_Testsuite_CheckNpc(var string name) {
    if (!G1CP_IsNpcInst(name)) {
        G1CP_TestsuiteErrorDetailSSS("NPC instance '", name, "' not found");
        G1CP_TestsuiteStatusPassed = FALSE;
        return -1;
    };
    return MEM_GetSymbolIndex(name);
};

/*
 * Check if function exists
 */
func int G1CP_Testsuite_CheckFunc(var string name, var string signature, var string funcType) {
    if (Hlp_StrCmp(funcType, "")) {
        funcType = "Function";
    };
    if (!G1CP_IsFunc(name, signature)) {
        G1CP_TestsuiteErrorDetailSSSS(funcType, " '", name, "' not found");
        G1CP_TestsuiteStatusPassed = FALSE;
        return -1;
    };
    return MEM_GetSymbolIndex(name);
};

/*
 * Check if dialog function exists
 */
func int G1CP_Testsuite_CheckDialogFunc(var string name) {
    return G1CP_Testsuite_CheckFunc(name, "void|none", "Dialog function");
};

/*
 * Check if dialog condition function exists
 */
func int G1CP_Testsuite_CheckDialogConditionFunc(var string name) {
    return G1CP_Testsuite_CheckFunc(name, "int|none", "Dialog condition");
};

/*
 * Check if AI state start function exists
 */
func int G1CP_Testsuite_CheckAiStateStartFunc(var string name) {
    return G1CP_Testsuite_CheckFunc(name, "void|none", "AI state");
};

/*
 * Check if AI state loop function exists
 */
func int G1CP_Testsuite_CheckAiStateLoopFunc(var string name) {
    return G1CP_Testsuite_CheckFunc(name, "|none", "AI state loop"); // Returns either int or void
};

/*
 * Check if AI state end function exists
 */
func int G1CP_Testsuite_CheckAiStateEndFunc(var string name) {
    return G1CP_Testsuite_CheckFunc(name, "void|none", "AI state end");
};

/*
 * Check if AI state (all functions) exists
 */
func void G1CP_Testsuite_CheckAiState(var string name) {
    var int i;
    i = G1CP_Testsuite_CheckAiStateStartFunc(name);
    i = G1CP_Testsuite_CheckAiStateLoopFunc(ConcatStrings(name, "_Loop"));
    i = G1CP_Testsuite_CheckAiStateEndFunc(ConcatStrings(name, "_End"));
};
