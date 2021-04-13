/*
 * Test suite
 *
 * Tests are called from the console with 'test ID' or 'test all'.
 * The corresponding functions 'G1CP_Test_000' (three digits) are called if found.
 *
 * The test functions should either return TRUE (if passed) or FALSE (if failed). They may also have no
 * return type, then they will be marked as to be manually confirmed.
 *
 * Errors and other messages should not be reported to the zSpy directly but using this function instead
 *    G1CP_TestsuiteErrorDetail(string message)
 *
 * Tests that require manual confirmation from the user typically have to teleport the hero or similar. This would
 * interfere when all tests are run at once (i.e. 'test all'). Therefore, before any such actions are taken, the test
 * function should check whether 'G1CP_TestsuiteAllowManual' is TRUE. This is the case when the test is run
 * specifically with 'test ID'.
 */

/* Collect error details */
const string G1CP_TestsuiteMsg = "";

/* Allow or disallow manual tests */
const int G1CP_TestsuiteAllowManual = 0;

/* Check if test passes */
const int G1CP_TestsuiteStatusPassed = 1;

/*
 * Initialization function
 */
func int G1CP_Testsuite() {
    CC_Register(G1CP_TestsuiteList, "test list", "List all tests of G1CP");
    CC_Register(G1CP_TestsuiteAll, "test all", "Run complete test suite for G1CP");
    CC_Register(G1CP_TestsuiteCmd, "test ", "Run test from test suite for G1CP");

    // Confirm registration
    return ((CC_Active(G1CP_TestsuiteList))
         && (CC_Active(G1CP_TestsuiteAll))
         && (CC_Active(G1CP_TestsuiteCmd)));
};

/*
 * Run test by id
 */
func int G1CP_TestsuiteRun(var int id) {
    var string idName; idName = G1CP_LFill(IntToString(id), "0", 3);

    // Reset test status
    G1CP_TestsuiteStatusPassed = TRUE;

    // Find test function
    var string funcName; funcName = ConcatStrings("G1CP_Test_", idName);
    var int symbPtr; symbPtr = MEM_GetSymbol(funcName);
    if (!symbPtr) {
        return -1;
    };

    // Call test function and return
    MEM_CallByString(funcName);
    if (MEM_ReadInt(symbPtr+zCParSymbol_offset_offset) == (zPAR_TYPE_INT >> 12)) {
        return MEM_PopIntResult();
    };
    return 2; // = No output
};

/*
 * Add error message (to be printed in the end)
 */
func void G1CP_TestsuiteErrorDetail(var string msg) {
    if (!Hlp_StrCmp(G1CP_TestsuiteMsg, "")) {
        G1CP_TestsuiteMsg = ConcatStrings(G1CP_TestsuiteMsg, "|");
    };

    // Obtain test number: Find the test function that that the call originated from
    var int id; id = 0;
    var int ESP; ESP = MEM_GetFrameBoundary();
    while(MEMINT_IsFrameBoundary(ESP) && (!id));
        ESP += MEMINT_DoStackFrameSize;
        var int popPos; popPos = MEM_ReadInt(ESP - MEMINT_DoStackPopPosOffset);
        if (popPos > 0) && (popPos < MEM_Parser.stack_stacksize) {
            var int funcId; funcId = MEM_GetFuncIDByOffset(popPos);
            var string funcName; funcName = MEM_ReadString(MEM_GetSymbolByIndex(funcId));
            var int prefixLen; prefixLen = STR_Len("G1CP_Test_000");
            if (STR_Len(funcName) >= prefixLen) {
                var int chr; chr = STR_GetCharAt(funcName, prefixLen-3) - 48;
                if (0 <= chr) && (chr <= 9) {
                    id = STR_ToInt(STR_SubStr(funcName, prefixLen-3, 3));
                };
            };
        };
    end;

    G1CP_TestsuiteMsg = ConcatStrings(G1CP_TestsuiteMsg, "  Test ");
    G1CP_TestsuiteMsg = ConcatStrings(G1CP_TestsuiteMsg, G1CP_LFill(IntToString(id), " ", 3));
    G1CP_TestsuiteMsg = ConcatStrings(G1CP_TestsuiteMsg, ": ");
    G1CP_TestsuiteMsg = ConcatStrings(G1CP_TestsuiteMsg, msg);
};
func void G1CP_TestsuiteErrorDetailSSS(var string s1, var string s2, var string s3) {
    G1CP_TestsuiteErrorDetail(ConcatStrings(ConcatStrings(s1, s2), s3));
};
func void G1CP_TestsuiteErrorDetailSIS(var string s1, var int i2, var string s3) {
    G1CP_TestsuiteErrorDetail(ConcatStrings(ConcatStrings(s1, IntToString(i2)), s3));
};
func void G1CP_TestsuiteErrorDetailSSSS(var string s1, var string s2, var string s3, var string s4) {
    G1CP_TestsuiteErrorDetail(ConcatStrings(ConcatStrings(ConcatStrings(s1, s2), s3), s4));
};

/*
 * Print error messages
 */
func void G1CP_TestsuitePrintErrors() {
    if (Hlp_StrCmp(G1CP_TestsuiteMsg, "")) {
        return;
    };
    var int count; count = STR_SplitCount(G1CP_TestsuiteMsg, "|");
    MEM_Info("");
    MEM_SendToSpy(zERR_TYPE_FAULT, ConcatStrings(IntToString(count), " errors occurred."));
    repeat(i, count); var int i;
        MEM_SendToSpy(zERR_TYPE_FAULT, STR_Split(G1CP_TestsuiteMsg, "|", i));
    end;
    MEM_Info("");
};

/*
 * Command handler
 */
func string G1CP_TestsuiteAll(var string _) {
    var int passed; passed = 0;
    var int failed; failed = 0;
    var int manual; manual = 0;
    var string msg;
    var string infos; infos = "";

    // Do not trigger manual tests
    G1CP_TestsuiteAllowManual = FALSE;

    // Reset test status
    G1CP_TestsuiteStatusPassed = TRUE;

    // Remember the data stack position
    var int stkPosBefore; stkPosBefore = MEM_Parser.datastack_sptr;

    // Iterate over and call all tests
    repeat(i, G1CP_SymbEnd); var int i; if (!i) { i = G1CP_SymbStart; }; // From SymbStart to SymbEnd

        var zCPar_Symbol symb; symb = _^(MEM_GetSymbolByIndex(i));
        if (STR_StartsWith(symb.name, "G1CP_TEST_"))
        && (STR_Len(symb.name) == 13)
        && ((symb.bitfield & zCPar_Symbol_bitfield_type) == zPAR_TYPE_FUNC) {
            // Test name
            msg = STR_SubStr(symb.name, 5, 8);

            // Check if currently applied or not
            var int id; id = STR_ToInt(STR_SubStr(symb.name, 10, 3));
            if (G1CP_IsFixApplied(id)) {
                msg = ConcatStrings(msg, " .");
            } else {
                msg = ConcatStrings(msg, "* ");
            };
            msg = ConcatStrings(msg, "... ");

            // Reset the data stack position and call the test function
            MEM_Parser.datastack_sptr = stkPosBefore;
            MEM_CallByID(i);

            if (symb.offset == (zPAR_TYPE_INT >> 12)) {
                if (MEM_PopIntResult()) {
                    msg = ConcatStrings(msg, "[PASSED]|");
                    infos = ConcatStrings(infos, msg);
                    passed += 1;
                } else {
                    msg = ConcatStrings(msg, "[FAILED]|");
                    infos = ConcatStrings(infos, msg);
                    failed += 1;
                };
            } else {
                msg = ConcatStrings(msg, "[MANUAL]|");
                infos = ConcatStrings(infos, msg);
                manual += 1;
            };
        };
    end;

    // Print infos (afterwards all together)
    MEM_Info("");
    var int count; count = STR_SplitCount(infos, "|");
    repeat(i, count-1);
        msg = STR_Split(infos, "|", i);
        if (STR_IndexOf(msg, "PASSED") != -1) {
            MEM_SendToSpy(zERR_TYPE_WARN, msg);
        } else if (STR_IndexOf(msg, "FAILED") != -1) {
            MEM_SendToSpy(zERR_TYPE_FAULT, msg);
        } else {
            MEM_SendToSpy(zERR_TYPE_INFO, msg);
        };
    end;
    MEM_Info("");

    // Print error details
    G1CP_TestsuitePrintErrors();
    G1CP_TestsuiteMsg = "";

    msg = IntToString(passed);
    msg = ConcatStrings(msg, " passed, ");
    msg = ConcatStrings(msg, IntToString(failed));
    msg = ConcatStrings(msg, " failed, ");
    msg = ConcatStrings(msg, IntToString(manual));
    msg = ConcatStrings(msg, " require manual confirmation. See zSpy for details.");
    return msg;

};

func string G1CP_TestsuiteCmd(var string command) {
    var int retInt;
    var string retStr;

    // Allow to trigger manual tests
    G1CP_TestsuiteAllowManual = TRUE;

    // Reset error details
    G1CP_TestsuiteMsg = "";

    retInt = G1CP_TestsuiteRun(STR_ToInt(command));
    if (retInt == -1) {
        retStr = "";
    } else if (retInt == 2) {
        retStr = "EXECUTED. Manual confirmation needed.";
    } else if (retInt == TRUE) {
        retStr = "PASSED";
    } else {
        retStr = "FAILED";
    };

    // Print error details
    G1CP_TestsuitePrintErrors();
    G1CP_TestsuiteMsg = "";

    return retStr;
};

func string G1CP_TestsuiteList(var string _) {
    var string automatic; automatic = "Automatic: ";
    var string manual;    manual    = "Manual:    ";

    // Iterate over and call all tests
    repeat(i, G1CP_SymbEnd); var int i; if (!i) { i = G1CP_SymbStart; }; // From SymbStart to SymbEnd

        // Compare symbol name
        var zCPar_Symbol symb; symb = _^(MEM_GetSymbolByIndex(i));
        if (STR_StartsWith(symb.name, "G1CP_TEST_"))
        && (STR_Len(symb.name) == 13)
        && ((symb.bitfield & zCPar_Symbol_bitfield_type) == zPAR_TYPE_FUNC) {
            var string msg;

            // Get test ID
            var int id; id = STR_ToInt(STR_SubStr(symb.name, 10, 3));
            msg = IntToString(id); // Trim leading zeros

            // Check if fix is not applied
            if (!G1CP_IsFixApplied(id)) {
                msg = ConcatStrings(ConcatStrings("(", msg), ")");
            };

            // Check if manual or automatic
            if (symb.offset == (zPAR_TYPE_INT >> 12)) {
                automatic = ConcatStrings(ConcatStrings(automatic, msg), " ");
            } else {
                manual = ConcatStrings(ConcatStrings(manual, msg), " ");
            };
        };
    end;

    // Remove trailing commas
    automatic = STR_Prefix(automatic, STR_Len(automatic)-1);
    manual = STR_Prefix(manual, STR_Len(manual)-1);

    // Format and return strings
    var string ret;
    if (SB_New()) {
        SB(automatic);
        if (Hlp_StrCmp(automatic, "Automatic:")) {
            SB(" None");
        };
        SBc(10);
        SBc(13);
        SB(manual);
        if (Hlp_StrCmp(manual, "Manual:   ")) {
            SB(" None");
        };
        ret = SB_ToString();
        SB_Destroy();
    };

    return ret;
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
