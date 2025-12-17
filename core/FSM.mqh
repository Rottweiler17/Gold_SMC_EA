#ifndef FSM_MQH
#define FSM_MQH

enum FSM_STATE
{
   WAIT_ASIA,
   WAIT_LIQUIDITY,
   WAIT_CHOCH,
   WAIT_DISPLACEMENT,
   WAIT_ENTRY_ZONE,
   WAIT_FVG,
   ENTRY,
   MANAGEMENT
};

FSM_STATE fsmState = WAIT_ASIA;

// Reset FSM cleanly
void ResetFSM()
{
   fsmState = WAIT_ASIA;
}

#endif
