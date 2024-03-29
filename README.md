crispyhardware
==============

C.R.I.S.P.Y Hardware is all about tools to help you debug hardware faster.

These are cloud connected hardware debug tools that help you follow the C.R.I.S.P.Y. checklist.

<p>&nbsp;</p>
<p>Debugging digital hardware design is not the same as debugging software.</p>
<p>You may have very strong software debugging skills. &nbsp;But I have found that those skills assume that the design is behaving as a digital system. &nbsp;If your hardware design has bugs at the analog level, it can cause the digital behavior to appear unpredictable. &nbsp;This behavior can be very frustrating to debug.</p>
<p><span>I want to share a method that I teach and use to reduce this frustration. &nbsp;This is a checklist that y<span>ou</span> can remember using the <span>cutesy</span> mnemonic device 'CRISPY'. &nbsp;</span></p>
<p>The CRISPY checklist is:</p>
<ul>
<li><strong><span style="font-weight: bold; text-decoration: underline;">C</span></strong>locks</li>
<li><strong><span style="text-decoration: underline;">R</span></strong><span><span>eset</span></span></li>
<li><strong><span style="text-decoration: underline;">I</span></strong><span><span>ntegrity</span> of </span><span style="text-decoration: underline;"><strong>S</strong></span><span><span>ignals</span></span></li>
<li><span style="text-decoration: underline;"><strong>P</strong></span><span><span>ower</span></span></li>
<li><strong><span style="text-decoration: underline;">Y</span></strong><span><span>ou</span></span></li>
</ul>
<p><span>As the mnemonic does not list the items in the best order, I will explain each item below in the order I have found most useful. &nbsp;I will also be relatively brief in this post. &nbsp;If y<span>ou</span> have questions about terms I use or tools needed just ask @<span>duppy</span> on twitter #<span>crispyhw</span> tag. &nbsp;If y<span>ou</span> have better solutions or a problem whose fix did not fit into this checklist, <span>please</span> share on twitter @<span>duppy</span> #<span>crispyhw</span>. &nbsp;I'll bet somebody out there has an even better checklist than this one.</span></p>
<ul>
<li><strong><span style="text-decoration: underline;">P</span></strong><span style="text-decoration: underline;"><span><span>ower</span></span></span> 
<ul>
<li>Are power and ground shorted?     
<ul>
<li>I had to ask. &nbsp; It is a good habit to "buzz out" all power and ground signals after every circuit mod <strong>before</strong><span>&nbsp;applying p<span>ower</span>.</span></li>
</ul>
</li>
<li>Is your design plugged in?     
<ul>
<li>Seriously. &nbsp;Double check with a voltmeter or LED.</li>
<li>If battery powered, is the battery near full? &nbsp;I recommend replacing the battery with a bench supply while debugging.</li>
<li>What chemistry battery are you using? &nbsp;Remember the voltage levels and discharge curves vary, that 1.5v AAA may actually only be 1.2V by design.</li>
</ul>
</li>
<li>Are you using too much power?     
<ul>
<li>A good bench supply will tell you how much <strong>average </strong>current is being drawn. &nbsp;The average will catch some but not all issues.</li>
<li>A good bench supply will also have a current limiting feature. &nbsp;Are you allowing sufficient power?</li>
<li><span>Often your micro will boot fine and only fail when y<span>ou</span> start turning on more modules or clocks or driving too many <span>LEDs</span> or motors. Radios (BLE, Wi-FI) and displays may also cause brown outs. &nbsp;The failure level can vary greatly from chip to chip. &nbsp;Use a bench supply when possible during debugging, add extra <span>LEDs</span> on purpose to stress p<span>ower</span>, or write specific firmware to intentionally turn on as many of the <span>micro's</span> internal modules and clocks to stress p<span>ower</span>.</span></li>
</ul>
</li>
<li>Is the resistance of your power cable too high (often because it is too long)?     
<ul>
<li><span>This is more common when <span>breadboarding</span>. &nbsp;Check p<span>ower</span> at the p<span>ower</span> pin of each <span>IC</span>, not at the p<span>ower</span> supply.</span></li>
</ul>
</li>
<li>If you are using a motor, add a diode!     
<ul>
<li>See this great tutorial for <a href="http://itp.nyu.edu/physcomp/Tutorials/HighCurrentLoads#toc4">driving a motor</a>.</li>
</ul>
</li>
<li>Are you using bypass capacitors of the correct value and more importantly placement?     
<ul>
<li><span>Bypass capacitors can be especially tricky because often modern <span>ICs</span> will work fine without them. &nbsp; Until they don't.</span></li>
<li><span>Also, larger is not better with bypass caps and too small doesn't work either. &nbsp;The value and type needed can also change when going from breadboard to <span>PCB</span>.</span></li>
<li><span>When in doubt, y<span>ou</span> can almost never go wrong with using 0.1<span>uF</span> caps near each <span>IC</span> p<span>ower</span> pin and 10<span>uF</span> at the main p<span>ower</span> source. </span> 
<ul>
<li>Very rarely will you need to delve deeper than the above recommendation. &nbsp;If you do, start with these links.     
<ul>
<li><a href="http://www.seattlerobotics.org/encoder/jun97/basics.html">Seattle Robotics</a>&nbsp;</li>
<li><a href="http://www.vagrearg.org/content/decoupling"><span><span>vagrearg</span>.<span>org</span></span></a></li>
</ul>
</li>
</ul>
</li>
</ul>
</li>
<li>Do you have more than one power domain?     
<ul>
<li><span><span>Remember</span> that a debug or programming cable or connection to a PC may count as your second p<span>ower</span> domain.</span></li>
<li>Are all the power domains on?</li>
<li>What order are the power domains turning on and off?</li>
<li><span>Check for "<span>backdrive</span>". &nbsp;If an output from a powered <span>IC</span> or a pull-up resistor is driving a high input to an <span>IC</span> that is not powered, then y<span>ou</span> are <span>backdriving</span> that <span>IC</span>. &nbsp;The <span>backdriven</span> <span>IC's</span> behavior can range from appearing to work as if powered properly to releasing smoke. &nbsp;The releasing smoke behavior is the easy bug to find. &nbsp;The other behaviors are harder. </span> 
<ul>
<li><span>Can someone recommend a good reference for more on <span>backdrive</span>?</span></li>
</ul>
</li>
<li>Are you interfacing 1.8V, 3.3V logic to 5V logic?     
<ul>
<li><a href="http://www.sparkfun.com"><span><span>Sparkfun</span> </span></a>has some <a href="http://www.sparkfun.com/tutorials/65">tips</a>.</li>
<li><span>Also read the app notes from the <span>Downloads</span> tab on this </span><a href="https://www.adafruit.com"><span><span>adafruit</span> </span></a><a href="https://www.adafruit.com/products/757">product</a>.</li>
</ul>
</li>
</ul>
</li>
</ul>
</li>
<li><span style="text-decoration: underline;"><strong>R</strong><span><span>eset</span></span></span> 
<ul>
<li><span>Once your digital <span>ICs</span> have stable p<span>ower</span>, they still need a good R<span>eset</span> to start working.</span></li>
<li><span>Many <span>ICs</span> have internal P<span>ower</span> On Resets (<span>POR</span>) so y<span>ou</span> may have been lured into skipping this step. &nbsp;Don't ignore it <span>because</span> your debug cable needs r<span>eset</span> to work well and it is also often very convenient to r<span>eset</span> your system during testing without having to cycle p<span>ower</span>.</span></li>
<li>Check that any external reset signals are meeting the timing and voltage level requirements.</li>
<li><span>Check that all <span>ICs</span> that take a r<span>eset</span> (whether explicit signal or implicit <span>POR</span>) are getting r<span>eset</span> at the same time. &nbsp; If not, understand the consequences. &nbsp;Recently I work a lot with </span><a href="http://www.electricimp.com">Electric Imp</a>. &nbsp;In these designs it is tempting to 'reset' by removing and re-inserting the Electric Imp card. &nbsp;The problem is that this does not reset the other digital devices that the Imp talks to. &nbsp;Are you having this problem?</li>
<li>Do all ICs get reset when the controller gets an internal soft reset? &nbsp;For example, some I2C connected peripherals require a reset command to be sent over the bus, but if the controller resets while the target is responding with a data low, hte I2C bus may get hung.</li>
</ul>
</li>
<li><span style="text-decoration: underline;"><strong>C</strong>locks</span> 
<ul>
<li><span>Even if P<span>ower</span> and R<span>eset</span> are good, your <span>ICs</span> still don't work without a stable clock. &nbsp;Like r<span>eset</span>, many <span>ICs</span> these days have internal <span>oscillators</span> so you might have also been lured into skipping this step.</span></li>
<li><span>Read the <span>datasheet</span> and make sure y<span>ou</span> are providing everything necessary for the internal clock to work or your external crystal or oscillator&nbsp;to start up.</span></li>
<li><span>If y<span>ou</span> have multiple <span>ICs</span> with high speed clocks then y<span>ou</span> need to read up on jitter, skew, setup, hold, <span>metastability</span>, transmission line termination techniques, crosstalk, duty cycle, and probably a few other topics.</span></li>
<li><span>I don't mean to scare y<span>ou</span>. &nbsp; If y<span>ou</span> are using <span>Arduino</span> or similar class micro based designs, then high-speed clocks are probably not your problem. &nbsp; Learn enough to rule them out as a possible cause and look everywhere else first.</span></li>
</ul>
</li>
<li><span style="text-decoration: underline;"><strong>I</strong><span><span>ntegrity</span> of </span><strong>S</strong><span><span>ignals</span></span></span> 
<ul>
<li><span>This is more commonly called "Signal I<span>ntegrity</span>" when y<span>ou</span> aren't trying to make your checklist have a <span>cutesy</span> mnemonic.</span></li>
<li>Know the speed of all your external signals and start with anything faster than 1MHz.</li>
<li>Know which signals are edge vs. level sensitive. &nbsp;Level sensitive signals can look ugly as they change but must be stable around the setup and hold time of the receiving chip. Edge sensitive signals need to have clean changes and may need to be treated as <span style="text-decoration: underline;"><strong>C</strong>locks</span></li>
<li style="vertical-align: sub;">Lookup V<span style="vertical-align: sub; font-size: 80%;">IH</span>, V<span style="vertical-align: sub; font-size: 80%;">IL</span>, V<span style="vertical-align: sub; font-size: 80%;">OH</span>, V<span style="vertical-align: sub; font-size: 80%;">OL</span> , for your chips and understand what they mean.</li>
<li style="vertical-align: sub;">Check both your internal and external pull-up/down resistors. &nbsp; Use a 100K ohm resistor connected to VCC or GND and poke it at your IOs to see whether they are being actively driven, floating, or pulled up/down.</li>
<li>Are lows really low? &nbsp;Do you really meet GND level, or not quite?</li>
</ul>
</li>
<li><span style="text-decoration: underline;"><strong>Y</strong>ou</span> 
<ul>
<li><span style="text-decoration: underline;">Are you reading the docs <a href="http://www.imdb.com/title/tt0090605/quotes?item=qt0424789">right</a>?</span></li>
<li>Are you reading the right docs? &nbsp;Check for the latest version that matches your device. &nbsp;Check for separate errata.</li>
<li><span style="text-decoration: underline;">Do your pin numbers defined in your firmware match the schematic?</span></li>
<li><span style="text-decoration: underline;">Are you using the right register addresses? &nbsp;Are you accessing them as 16bit when they are only 8bit?</span></li>
<li><span style="text-decoration: underline;">Does the PCB as built match the schematic? &nbsp; Version control is not used as often in hobby hardware development as it is in software development. &nbsp;It should be.</span></li>
<li><span style="text-decoration: underline;">Is your scope or multimeter connected to the right pin? &nbsp;Pin one labeling can often be confusing and it can be hard to count fine pitch pins. &nbsp;Use labeled test points. &nbsp;Don't skimp on annotating your silk screen or use different color breadboard wires in some consistent manner such as red for power, black for ground, blue for IOs, green for clocks.</span></li>
<li><span style="text-decoration: underline;">Are you assuming a pin is active high when it is really active low?</span></li>
<li><span style="text-decoration: underline;">Are your clocks rising or falling edge?</span></li>
<li>Have you set your LA/scope trigger levels right? &nbsp;With a mix of 1.1V, 1.8V, 3.3V and 5V technologies, is your trigger level all embracing, or did you set it too high, or too low? &nbsp;A 5V low can be higher than a 1.1V high.</li>
<li><span style="text-decoration: underline;">If you have a serial bus is it sending LSB or MSB first?</span></li>
</ul>
</li>
</ul>
<p>I hope you find this checklist helpful. &nbsp;Share a story if it helps you find a bug. &nbsp;If you find a bug that doesn't fit into one of these categories, share that also.</p>
<p><span style="font-style: italic;">To discuss: Reply on Twitter @</span><span style="font-style: italic;">duppy</span><span style="font-style: italic;"> with #</span><span style="font-style: italic;">crispyhw</span><span style="font-style: italic;"> tag.</span></p>
