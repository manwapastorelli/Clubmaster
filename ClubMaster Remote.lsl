default
{  
    touch_start(integer any)
    {
        key toucher = llDetectedKey(0);
        integer RemoteChannel = -741285681;
        llRegionSay(RemoteChannel, (string)toucher);
    }
}