/*
 * #158 Potion of Haste has wrong ore value
 *
 * The value of the item "ItFo_Potion_Haste_03" is inspected programmatically.
 *
 * Expected behavior: The item will have the correct value.
 */
func int G1CP_Test_0158() {
    var C_Item itm; itm = G1CP_Testsuite_CreateItem("ItFo_Potion_Haste_03");
    const int Value_Haste3 = 0; Value_Haste3 = G1CP_Testsuite_GetIntConst("Value_Haste3", 0);
    G1CP_Testsuite_CheckPassed();

    if (itm.value == Value_Haste3) {
        return TRUE;
    } else {
        G1CP_TestsuiteErrorDetailSIS("Category incorrect: value = '", itm.value, "'");
        return FALSE;
    };
};
