/*
 * #124 Gate guard doesn't close castle gate in chapter 4
 */
func int G1CP_124_GateGuardId() {
    return G1CP_NpcChangeIntVar("GRD_280_Gardist", "id", 230, 280);
};
