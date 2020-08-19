// CLUBMASTER POSEBALL SCRIPT v2.0
// by Aine Caoimhe Sept 2014 / Jan. 2016
// Provided under Creative Commons Attribution-Non-Commercial-ShareAlike 4.0 International license.
// Please be sure you read and adhere to the terms of this license: https://creativecommons.org/licenses/by-nc-sa/4.0/
//
// There should never be a need to edit this poseball script as all relevant paramters are set in the main script and passed to this one
//
// ******************************************************************************
// * DO NOT CHANGE ANYTHING BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING! *
// ******************************************************************************
vector ballColour;
key controller=NULL_KEY;
integer enableParticles=FALSE;
float killTimer=0;
key userID=NULL_KEY;
key lastUser=NULL_KEY;
integer killingBall=FALSE;
vector myZ=ZERO_VECTOR;
integer zActive=FALSE;
float zStep;
vector basePos;
float zGlobal;
rotation baseRot;
string killBallReason;
string myName;
integer faceIn=1;
integer faceLat=0;

initializeZ() {
    llRequestPermissions(userID,PERMISSION_TAKE_CONTROLS);
}
releaseZ() {
    zActive=FALSE;
    llReleaseControls();
}
moveTo(vector pos, rotation rot) {
    if (llVecDist(llGetPos(),pos)>64.0) {
        llOwnerSay("ERROR! Told to move to "+(string)pos+" which is more than 64m away from my current position "+(string)llGetPos());
        return;
    }
    while (llVecDist((pos+myZ),llGetPos())>0.001) { llSetLinkPrimitiveParamsFast(LINK_ROOT,[PRIM_POSITION,pos+myZ,PRIM_ROTATION,rot]); }
}
setParticles(integer on) {
    if (on && enableParticles) llParticleSystem([  PSYS_PART_MAX_AGE,0.7,PSYS_PART_FLAGS,0|PSYS_PART_EMISSIVE_MASK|PSYS_PART_INTERP_COLOR_MASK|PSYS_PART_INTERP_SCALE_MASK|PSYS_PART_FOLLOW_SRC_MASK|PSYS_PART_FOLLOW_VELOCITY_MASK|PSYS_PART_TARGET_POS_MASK,PSYS_PART_START_COLOR,ballColour,PSYS_PART_END_COLOR,<1,1,1>,PSYS_PART_START_SCALE,<0.05,0.05,0>,PSYS_PART_END_SCALE,<0.1,0.1,0>,PSYS_SRC_PATTERN,PSYS_SRC_PATTERN_EXPLODE,PSYS_SRC_BURST_RATE,0.1,PSYS_SRC_BURST_PART_COUNT,5,PSYS_SRC_BURST_RADIUS,2,PSYS_SRC_BURST_SPEED_MIN,2.25,PSYS_SRC_BURST_SPEED_MAX,2.25,PSYS_SRC_TARGET_KEY,llGetKey(),PSYS_SRC_ANGLE_BEGIN,1.55,PSYS_SRC_ANGLE_END,1.54,PSYS_PART_START_ALPHA,0.75,PSYS_PART_END_ALPHA,0.5]);
    else llParticleSystem([]);
}
setText(integer on) {
    if (on) llSetText("Dance",ballColour,1.0);
    else llSetText("",<0,0,0>,0.0);
}
showBall (string mode) {
    float alphaLat=1.0;
    float alphaIn=0.33;
    vector size=<0.35,0.35,0.35>;
    integer textOn=TRUE;
    integer partOn=TRUE;
    if (mode=="HIDE") {
        alphaLat=0.0;
        alphaIn=0.0;
        size=<0.01,0.01,0.01>;
        textOn=FALSE;
        partOn=FALSE;
    } else if (mode=="EDIT") {
        alphaLat=0.0;
        alphaIn=0.5;
        size=<0.1,0.1,3.0>;
        textOn=FALSE;
        partOn=FALSE;
    } else if (mode!="SHOW") llOwnerSay("ERROR: unexpectected mode passed: "+mode);
    llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_SIZE,size,PRIM_COLOR,faceIn,ballColour,alphaIn,PRIM_COLOR,faceLat,ballColour,alphaLat]);
    setText(textOn);
    setParticles(partOn);
}
killBall() {
    if (userID!=NULL_KEY) {
        killingBall=TRUE;
        releaseZ();
        if (llGetAgentSize(userID)!=ZERO_VECTOR) {
            if (llAvatarOnSitTarget()==userID) llUnSit(userID);
            osAvatarPlayAnimation(userID,"stand");
            osAvatarStopAnimation(userID,llGetInventoryName(INVENTORY_ANIMATION,0));
        }
    }
    if ((killBallReason!="CALLED_BY_CONTROLLER") && (controller!=NULL_KEY)) osMessageObject(controller,"KILL_BALL_CALLED|"+killBallReason);
    if (killBallReason!="CALLED_BY_CONTROLLER") llSay(0,"Killing ball: "+killBallReason);
    llDie();
}
updateSitTarget(vector pos, rotation rot) {
    // Written by Strife Onizuka, size adjustment and improvements provided by Talarus Luan (http://wiki.secondlife.com/wiki/LlSitTarget#Useful_Snippets)
    // further adapted by Aine Caoimhe for greater efficiency for this system and to adjust for supplied global z-offset setting
    if(userID!=NULL_KEY) {
        vector size=llGetAgentSize(userID);
        if(size!=ZERO_VECTOR) {
            integer linkNum = llGetNumberOfPrims();
            do {
                if(userID == llGetLinkKey( linkNum )) {
                    float fAdjust=((((0.008906*size.z)-0.049831)*size.z)+0.088967)*size.z;
                    llSetLinkPrimitiveParamsFast(linkNum,[PRIM_POS_LOCAL,(pos+<0.0,0.0,0.4>)-(llRot2Up(rot)*fAdjust),PRIM_ROT_LOCAL,rot]);
                    jump end;
                }
            } while( --linkNum );
        } else {
            llRegionSayTo(userID,0,"Experienced a minor glitch setting your sit position, please try sitting again");
            llUnSit(userID);
        }
    }
    @end;
}
default
{
    state_entry()
    {
        llSitTarget(<0,0,0.00001>,ZERO_ROTATION);
        llSetClickAction(CLICK_ACTION_SIT);
        showBall("SHOW");
    }
    on_rez(integer startParam)
    {
        showBall("SHOW");
        if (llGetAttached()>0) return;
        controller=osGetRezzingObject();
        if (controller==NULL_KEY) {
            killBallReason="ERROR! Ball rezzed with NULL_KEY controller so it doesn't know who to send messages to. If you want to edit the script, wear the ball instead. Ball deleted from scene.";
            killBall();
        }
        if (startParam==0) {
            killBallReason="ERROR! Ball rezzed with no start parameter so it can't identify itself to the controller. Ball deleted from scene.";
            killBall();
        } else {
            basePos=llGetPos();
            baseRot=llGetRot();
            ballColour=<1,1,1>;
            killTimer=0;
            userID=NULL_KEY;
            lastUser=NULL_KEY;
            killingBall=FALSE;
            myZ=ZERO_VECTOR;
            myName=llGetObjectName();
            zActive=FALSE;
            zStep=0.01;
            killBallReason="ERROR! Balled received no response from the controller for initial positioning location";
            llSetTimerEvent(5.0);
            osMessageObject(controller,"BALL_REZZED|"+(string)startParam);
            llSetObjectName(myName+"_"+(string)startParam+" (empty)");
        }
    }
    changed (integer change)
    {
        if (change & CHANGED_LINK) {
            userID=llAvatarOnSitTarget();
            if (userID==NULL_KEY) {
                if(!killingBall) {
                    osAvatarPlayAnimation(lastUser,"stand");
                    osAvatarStopAnimation(lastUser,llGetInventoryName(INVENTORY_ANIMATION,0));
                    releaseZ();
                    zActive=FALSE;
                    myZ=ZERO_VECTOR;
                    osMessageObject(controller,"USER_STOOD|"+(string)lastUser);
                    lastUser=NULL_KEY;
                    llSetTimerEvent(killTimer);
                    killBallReason="USER_STOOD_TIMEOUT";
                    showBall("SHOW");
                    moveTo(basePos,baseRot);
                }
            } else {
                llSetTimerEvent(0.0);
                killBallReason="";
                lastUser=userID;
                updateSitTarget(<0.0,0.0,zGlobal>,ZERO_ROTATION);
                list anToStop=llGetAnimationList(userID);
                osAvatarPlayAnimation(userID,llGetInventoryName(INVENTORY_ANIMATION,0));
                integer a=llGetListLength(anToStop);
                while (--a>-1) { osAvatarStopAnimation(userID,llList2String(anToStop,a)); }
                showBall("HIDE");
                osMessageObject(controller,"USER_SAT|"+(string)userID);
                llSetObjectName(myName+" (occupied)");
            }
        } else if (change & CHANGED_REGION_START) llDie(); // kill stranded
    }
    timer()
    {
        killBall();
    }
    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_TAKE_CONTROLS) {
            zActive=TRUE;
            llTakeControls(0|CONTROL_UP|CONTROL_DOWN,TRUE,FALSE);
        }
    }
    control(key id, integer level, integer edge)
    {
        integer press = level & edge;
        if (press & CONTROL_UP) {
            vector curPos=llGetPos();
            myZ.z+=zStep;
            llSetLinkPrimitiveParamsFast(LINK_ROOT,[PRIM_POSITION,curPos+<0,0,zStep>]);
        } else if (press & CONTROL_DOWN) {
            vector curPos=llGetPos();
            myZ.z-=zStep;
            llSetLinkPrimitiveParamsFast(LINK_ROOT,[PRIM_POSITION,curPos+<0,0,-zStep>]);
        }
    }
    dataserver (key id, string data)
    {
        if (id!=controller) return;
        list message=llParseString2List(data,["|"],[]);
        string command=llList2String(message,0);
        if (command=="SHOW_BALL") showBall("SHOW");
        else if (command=="HIDE_BALL") showBall("HIDE");
        else if (command=="EDIT_BALL") {
            releaseZ();
            myZ=ZERO_VECTOR;
            showBall("EDIT");
        } else if (command=="MOVE_BALL") moveTo(llList2Vector(message,1),llList2Rot(message,2));
        else if (command=="MOVE_AND_SHOW_BALL") {
            basePos=llList2Vector(message,1);
            baseRot=llList2Rot(message,2);
            killTimer=llList2Float(message,3);
            zGlobal=llList2Float(message,4);
            enableParticles=llList2Integer(message,5);
            if (killTimer<0) {
                ballColour=<1.0,0,1.0>;
                killTimer*=-1;
            } else ballColour=<0.0,0.0,1.0>;
            moveTo(basePos,baseRot);
            showBall("SHOW");
            killBallReason="NO_USER_SAT";
            llSetTimerEvent(killTimer);
        } else if (command=="ENABLE_Z") {
            zStep=llList2Float(message,1);
            initializeZ();
        } else if (command=="DISABLE_Z") releaseZ();
        else if (command=="UNSET_Z") {
            llSetLinkPrimitiveParamsFast(LINK_ROOT,[PRIM_POSITION,llGetPos()-myZ]);
            myZ=ZERO_VECTOR;
        } else if (command=="KILL_BALL") {
            killBallReason="CALLED_BY_CONTROLLER";
            killBall();
        } else llOwnerSay("ERROR! Received a command I didn't understand: "+command);
    }
}
