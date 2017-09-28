# ards-firmwaretool
ARDS Firmware Tool is an all-in-one tool meant for regular users and developers alike to edit, extract and create NTRBoot compatible firmware files for the Action Replay DS/EZ/Media Edition/DSi. __You don't need to patch Code Manager to flash firmware files generated with this tool, as it automatically calculates the correct checksum for them!__ Not only that, but generated files also tend to be __very small__ as everything that's not needed is trimmed away (the file size of a firmware containing Boot9Strap v1.3 is only 62kb, _less than a third_ of the size of the previous implementation!)

_This program doesn't come with any implicit or explicit warranties. Whatever you do with it is your own responsability and, while every function except the DSi ones have been tested many times, by using this tool you're agreeing that I'm not liable of any damages made by using it._

The tool includes several functions:

* Simple NTRBoot firmware generation

__This function is meant for people following Plailect's guide and is meant to generate a firmware with Boot9Strap as fast and easily as possible__. You only need to select your ARDS model and click a button, then the tool will automatically download the lates B9S version for the internet and care about everything else. After generating the firmware you just need to flash it via Code Manager like any other firmware and you're done! (Things are a little bit different for an Action Replay DS Media Edition, read the "How to flash firmwares" section for that.)

* Advanced NTRBoot firmware generation:

Just like the Simple function, this is meant for people who want to use NTRBoot on their system, but with it __you can inject your own FIRMs (such as Godmode9 for NTRBoot) and it also works for both Retail and Devkit units__. As you need to provide your own FIRM files, this function works completely offline.

* Extract firmware from ROM

Do you want to restore your own ARDS to its previous state but you can't find your firmware online? No problem! ARDS Firmware Tool can __extract a flashable firmware file from an ARDS ROM dump.__ This is especially useful for ARDS ME users, as it's _the only way to restore an ARDS ME to working conditions after a NTRBoot install._

* Header tools

A collection of functions to view and edit ARDS firmware file headers. You can edit what ARDS model the firmware is supposed to be flashed on, fix its CRC, strip the header and obtain an NDS file that you can boot on a flashcart and even build a header for any file that you want to flash! (This last function is meant for devs and firmware whose headers have been stripped before, flashing an incorrect file will brick your ARDS and you'll only be able to recover it if you own a flashcart.)

### How to flash a firmware to an ARDS

Keep in mind that you need another Action Replay of your same model or a flashcart if you want to restore your ARDS/EZ/Media Edition to its previous condition after you've installed a NTRBoot compatible firmware! (See the "How to restore an ARDS" section for more info)

* Action Replay DS / EZ

You need a Nintendo DS/DS Lite, an USB cable for the ARDS and a PC with Code Manager (and appropriate drivers) installed.

1) Generate your own firmware using ARDS Firmware Tool. If you want to follow Plailect's guide then select your ARDS model in Simple NTRBoot firmware generation and click "Generate Firmware". Once done, a file called "ntrboot_ar.bin" will be created in the same directory as the tool - that's your firmware file.

2) Insert you ARDS in your DS/DS Lite and power it on. Connect the USB cable to the ARDS and your computer.

3) Open Code Manager. The ARDS should automatically enter USB mode (if not, click the mouse icon on the NDS. If it still doesn't get recognized by Code Manager then check that the ARDS is correctly inserted in Slot 1.)

4) Drag the firmware file on Code Manager's title bar. Wait until the firmware gets uploaded on the ARDS and, once done, click "Yes" when you're asked by Code Manager if you want to write it to the Action Replay.

5) Congratulations, your firmware has been written succesfully! Now you can follow the rest of Plailect's guide to softmod your 3DS.

* Action Replay DS Media Edition

You need a Nintendo DS/DS Lite, an USB cable for the ARDS, a 2GB or less MicroSD (non SDHC) and a PC with Code Manager (and appropriate drivers) installed.

__VERY IMPORTANT!__ You NEED to make a ROM backup before doing anything to your ARDS ME if you want to restore it afterwards! You can use the Media Edition functionality to boot NDS Backup Tool Wifi to do that without a flashcart (DO NOT ask me for a link to a ROM backup). __An official ARDS ME firmware file will NOT correctly restore your Action Replay!__ (Check the FAQ for more info)

1) Download the ARDS v1.71 firmware update from Datel's website and unzip it.

2) Open ARDS Firmware Tool and select Header Tools. Select the firmware you've just unzipped and click on "Strip header". It will ask you where you want to save the NDS file: put it somewhere you can find it easily.

3) Once it's done, copy that file to your MicroSD and put it in your ARDS Media Edition, then put the ARDS in your NDS/NDS Lite and boot it.

4) Go into Media Player and select the NDS file you've previously put on the MicroSD. The ARDS v1.71 firmware should boot.

5) From now on, follow the instructions on how to flash a firmware for Action Replay DS/EZ.

* Action Replay DSi

Even if it should work, this method is untested as I don't own an ARDSi. If for any reason it doesn't work, try using the patched DSi Code Manager provided by al3x_10m.
You need an USB cable for the ARDSi, and a PC with DSi Code Manager (and appropriate drivers) installed.

1) Generate your own firmware using ARDS Firmware Tool. If you want to follow Plailect's guide then select your ARDS model in Simple NTRBoot firmware generation and click "Generate Firmware". Once done, a file called "ntrboot_ar.bin" will be created in the same directory as the tool - that's your firmware file.

2) Connect the USB cable to the ARDS and open DSi Code Manager. Wait until you ARDSi is correctly recognized (Waiting for Action Replay Card should disappear).

3) Drag the firmware file and drop on the gray bar under ARDSi's title bar. When a popup appears, click OK and wait until DSi Code Manger asks if you want to apply changes, then click "Yes". Once it's done, click OK.

5) Congratulations, your firmware has been written succesfully! Now you can follow the rest of Plailect's guide to softmod your 3DS.

### How to restore an ARDS

* Action Replay DS/EZ/Media Edition

You need a flashcart that can boot your ARDS' firmware or another Action Replay of the same model of your own, a Nintendo DS/DS Lite, an USB cable for the ARDS and a PC with Code Manager (and appropriate drivers) installed.

1) -If you can find your firmware online or you've previously extracted a firmware-
Open ARDS Firmware Tool and select Header Tools. Select the firmware you've just unzipped and click on "Strip header". It will ask you where you want to save the NDS file: put it somewhere you can find it easily.

-If you have a ROM backup or if you own an ARDS ME-
Open ARDS Firmware Tool and select Extract Firmware from ROM. Select your firmware and select your ARDS model, then click on "Extract firmware". Save your firmware somewhere you can find it easily, then follow the previous point "If you can find your firmware online or you've previously extracted a firmware"

2) Copy your generated NDS file to your flashcart, put it in your NDS/NDS Lite and boot the NDS file. If you own another ARDS instead, put it in your NDS Lite and boot it, then connect the USB cable to it and to your computer.

3) Follow the guide on how to flash a firmware for your ARDS contained in this file, but this time flash the official firmware or the firmware you've previously extracted.

* Action Replay DSi

You need an USB cable for the ARDSi and a PC with Code Manager (and appropriate drivers) installed.

1) Connect the Action Replay DSi to your PC and open Code Manager DSi, then open DSi Code Manager and check that your ARDSi is correctly connected.

2) Click on the ARDSi logo (the four coloured dots) and select "About Action Replay DSi Code Manager...", then click on "Reset Hardware".

3) Wait until it's finished.

### FAQ

Q: Sometimes I get "Protocol error" when flashing FIRMs to my ARDS! What's up with that?

A: Nothing, just a bug with Code Manager. As long as your ARDS says "Reboot your NDS now!" on it, it means that your firmware has been flashed correctly!


Q: Why can I only flash FIRMs smaller than 1016321 bytes and firmware files smaller than 1 MB?

A: Through Code Manager we can only write to the first megabyte of an ARDS. Considering the few KBs used by the firmware's header, that's how much space is left to write a firmware. Still, that's plenty of space for a NTRBoot compatible firmware!


Q: Why can't you just link to an ARDS ME firmware generated by this tool instead of making me do a ROM dump and making my own.

A: I know Datel won't probably care but, legally speaking, that's copyright infringment as I'd be distributing copyrighted code written by Datel without their consent.


Q: Instead, do NTRBoot compatible firmwares generated by this tool contain any copyrighted content?

A: No. Every single bit of code made by Datel has been completely removed, so they're freely and legally redistributable!


Q: When extracting a firmware I get an error saying that the ROM is smaller than 1294336 bytes. What does that mean?

A: Your ROM is probably an improper dump created by stripping the header from a firmware file. Try to use the rebuild header function in the header tools tab.

Q: Why changing a firmware's header to get recognized as an ARDS ME firmware will cause an Action Replay to partially brick?

A: When Code Manager flashes an Action Replay DS Media Edition firmware, it will actually overwrite just a small portion of the internal NAND (the one containing the Action Replay code) and nothing else. That's not enough to install NTRBoot and will make you unable to use the Action Replay function. You can recover your ARDS ME by following the "How to restore an ARDS" guide I've posted before, but only if you made a ROM backup before.


Q: Why can't I use an official Action Replay DS Media Edition firmware to restore my own one?

A: See the question above.


Q: Why my antivirus detects this as a virus?

A: You can clearly see the source code of this tool and verify that's not doing anything malicious on your computer. Howerer, some antiviruses simply don't like AutoIt and immediately flag anything made with it as a virus. If your antivirus does that, either add ARDS Firmware Tool to the whitelist or change it altogether, as it's probably not a good one.


Q: Windows only? What about Linux/mac OS?

A: Code Manager only works on Windows, so it would be pretty pointless to make a version of this tool that runs on anything else than Windows.


Q: So, if I can flash ANY file to an Action Replay... does it mean that I can flash ROMs to it?

A: Quick answer - not really. More detailed answer - 1 MB is too small for any commercial ROM and you'll have to rearrange some stuff in order to match the internal structure of the ARDS' NAND. Homebrew ROMS are more likely to work, but I doubt any commercial ROM will likely work.

### Credits

* al3x_10m for the original NTRBoot on ARDS implementation

* stuckpixel (on #cakey) for its tips on how to port NTRBoot

* MsbhvnFC(on /r/3dshacks) for providing me with an official Action Replay DS Media Edition firmware file

* SciresM for Boot9Strap

* wraithdu - author of _Zip.au3

* roby - author of the _Crc16() function
