# Example for rescue board
Use Flyswatter2 ICD to rescue HGW-2502GX4TU-B which is used BCM4912 SoC.

## Generate GDB script files
1. compile Broadcom SDK
    ```shell
    SDK_DIR=$HOME/workspace/broadcom_504l02p1; \
    PROFILE=HGW_2502GX4TU_B; \
    cd $SDK_DIR && make PROFILE=$PROFILE; cd -
    ```
2. generate GDB script files and loader image
    ```shell
    SDK_DIR=$HOME/workspace/broadcom_504l02p1; \
    BRCM_CHIP=4912; \
    cd $SDK_DIR/bootloaders && make clean && \
    make BRCM_CHIP=$BRCM_CHIP uboot cmm; cd -
    ```
    **Note:**
    Use below commands to apply patch if ${PROFILE}.gdb not be generated.
    ```shell
    PATCH_FILE=$HOME/workspace/workaround-cmm_not_generate_if_mcb_is_4004152b.patch; \
    SDK_DIR=$HOME/workspace/broadcom_504l02p1; cd $SDK_DIR && \
    patch -p1 < $PATCH_FILE && cd -

    SDK_DIR=$HOME/workspace/broadcom_504l02p1; \
    BRCM_CHIP=4912; \
    cd $SDK_DIR/bootloaders && make clean && \
    make BRCM_CHIP=$BRCM_CHIP cmm; cd -
    ```

## To halt CPU (BCM4912)
1. power off the target board
2. connecting console to target board
3. keep to press key 'a' and power on the target board
4. for now, the target board should be booting to u-boot SPL stage, check it with console.
5. press key 'h' and then press Enter key, that will cause CPU halt\
    You may see below messages in console:
    ```
    U-Boot SPL 2019.07 (Oct 27 2021 - 18:02:52 +0800)
    Strap register: 0x7ffff1cb
    Board is non secure
    $SPL: 5.04L.02@348603 $
    Use enter to confirm input menu selection
    go - continue
    ddr - mcb override(hex) or DDR safe mode.
            ddr (3|4) safe modes;
            ddr <hex num>  passes selector value
    r - Boot Fallback; 1 - recovery
    bid - Ignore boardid while booting
    mcb - List all the mcb selectors
    h - halt
    h
    Halted
    ```

## Rescue the board
1. Connecting the Flyswatter2 to the board
2. Connecting the console (UART interface) to the board
3. Open terminal #1 to execute/start OpenOCD
    ```shell
    DOCKER_IMG_NAME="changhsinglee/alpine-openocd:latest"; \
    CONTAINER_NAME=openocd; \
    SDK_DIR=$HOME/workspace/broadcom_504l02p1; \
    BRCM_CHIP=4912; \
    docker run -it \
    --name $CONTAINER_NAME \
    -v $SDK_DIR/obj/cmm/$BCM_CHIP:/srv \
    --privileged --rm $DOCKER_IMG_NAME \
    openocd -s /srv -f /usr/share/openocd/scripts/interface/ftdi/flyswatter2.cfg -f ${BRCM_CHIP}.cfg
    ```
   You may see below messages on terminal #1 if you start OpenOCD successfully.
    ```
    Open On-Chip Debugger 0.11.0
    Licensed under GNU GPL v2
    For bug reports, read
    http://openocd.org/doc/doxygen/bugs.html
    DEPRECATED! use 'adapter speed' not 'adapter_khz'
    Warn : DEPRECATED! use '-baseaddr' not '-ctibase'
    core_up
    Info : Listening on port 6666 for tcl connections
    Info : Listening on port 4444 for telnet connections
    Info : clock speed 1000 kHz
    Info : JTAG tap: auto0.tap tap/device found: 0x0133017f (mfg: 0x0bf (Broadcom), part: 0x1330, ver: 0x0)
    Warn : JTAG tap: auto0.tap       UNEXPECTED: 0x0133017f (mfg: 0x0bf (Broadcom), part: 0x1330, ver: 0x0)
    Error: JTAG tap: auto0.tap  expected 1 of 1: 0x0f6aa17f (mfg: 0x0bf (Broadcom), part: 0xf6aa, ver: 0x0)
    Info : JTAG tap: auto1.tap tap/device found: 0x1d32017f (mfg: 0x0bf (Broadcom), part: 0xd320, ver: 0x1)
    Info : JTAG tap: bcm63146.tap tap/device found: 0x5ba00477 (mfg: 0x23b (ARM Ltd), part: 0xba00, ver: 0x5)
    Error: Trying to use configured scan chain anyway...
    Warn : Bypassing JTAG setup events due to errors
    Info : bcm63146.cpu0: hardware has 6 breakpoints, 4 watchpoints
    Info : bcm63146.cpu0 cluster 0 core 0 multi core
    Info : starting gdb server for bcm63146.cpu0 on 3333
    Info : Listening on port 3333 for gdb connections
    ```
	**Please to check cable connection between Flyswatter2 and JTAG connector if you got error!**
4. Open terminal #2 to execute GDB
    ```shell
    CONTAINER_NAME=openocd; \
    docker exec -it $CONTAINER_NAME gdb-multiarch
    ```
5. Use GDB to connect to OpenOCD and run GDB script to rescue board (in terminal #2)
    ```shell
    cd srv
    target remote :3333
    source HGW_2502GX4TU_B.gdb
    ```
    Try to [halt CPU](Flyswatter2-BCM4912.md#to-halt-cpu-bcm4912) and re-try this step if you got error.
