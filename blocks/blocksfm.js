// this version reduces the block size to 10x20

function preload() {
  d = loadJSON('assets/loudness.json');
  font = loadFont('assets/IBMPlexSans-Light.otf');
}

function Block(initX, color, transp, amt, floor) {
  this.gotinitframe = false;

  if (color == 'pink') { // alpha:
    this.r = 206; // 192;
    this.g = 13; // 12;
    this.b = 74; // 69;
  }
  else if (color == 'red') {
    this.r = 225;
    this.g = 40;
    this.b = 13;
  }
  else if (color == 'yelw') {
    this.r = 200;
    this.g = 214;
    this.b = 0; // 5;
  }
  else if (color == 'orng') {
    this.r = 225;
    this.g = 186;
    this.b = 13;
  }
  else if (color == 'turq') {
    this.r = 0;
    this.g = 158;
    this.b = 132;
  }
  else if (color == 'viol') {
    this.r = 92;
    this.g = 17;
    this.b = 228;
  }

  this.alpha = transp*255 // goal alpha




  this.fade = 0

  this.blocks = amt // code to determine how many blocks based on amt is unique to whatever the graph is visualizing

  // this.space = (this.blocks+1)*20 + (this.blocks*2); // this was nonsensically under appear before which was making this.space not work. changed it.
  this.space = this.blocks*10 + this.blocks*2;

  this.updated_flr = false;

  this.appear = function() {
    if(this.gotinitframe == false) {
      this.initframe = frameCount;
      this.gotinitframe = true;
    }

    this.elapsed = (frameCount - this.initframe) / 60; // secs elapsed

    // this.ypos = 100 + exp(4.5*(this.elapsed), 2);
    this.ypos = 100 + exp(5*(this.elapsed), 2);

    if(this.fade < this.alpha) {
      this.fade += 2
    }


    if(this.ypos >= floor - this.space) {
      this.ypos = floor - this.space
    }

    // RECTANGLES VERSION
    noStroke();
    fill(this.r, this.g, this.b, this.fade);
    rect(initX, this.ypos, 20, this.blocks*10 + (this.blocks-1)*2)


  }

}

function Floor() {
  this.f = 578
}

var para;
var git;

function setup() {
	var canvas = createCanvas(1000, 610);
  para = createDiv('');
  git = createDiv('');
  para.position(450, 116);
  para.style('width', '300px');
  para.style('font-family', '');
  git.position(556, 89);
  git.style('font-size', '11px')



}

var colors = ['pink', 'yelw', 'turq', 'viol'];
var transps = [0.2, 0.4, 0.6, 0.8, 1]
var amts = [1, 2, 3];

var blocks = []; // this will house each block as it gets created
var floors = [];

var months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];




function draw() {
  background(255, 255, 255);

  git.html("<a href= \"https://github.com/emilymo008/loudfm\">(https://emilymo008.github.io/loudfm/)</a>")


  for (var i = 1; i < 49; i++) {
    if(frameCount == i*30) {

      if (i % 12 == 0) { // horizontal position 1 thru 12
        r = 12
      }
      else (
        r = i % 12
      )

    if(i < 13) {
      floors.push(new Floor()); // make new floor
    }

    blocks.push(new Block(100+20*(r-1) + 2*r, // make new block
      colors[d[i-1].yrindex-1],
      // d[i-1].transparency / 20, // transparency rule for this specific data set
      (+d[i-1].transparency + +10) / 4,
      d[i-1].quantity / 120,
      floors[r-1].f));


    floors[r-1].f -= blocks[i-1].space; // update floor
    // console.log(floors[r-1].f)

    }


  }

  fill(0, 0, 0);
  // text(floors[0].f, 100, 100); //NOT WORKING but not important b/c console log told me the f value was correct

  for (var i = 0; i < blocks.length; i++) {
    blocks[i].appear()
  }

  // legend, labels, etc
  for (var i = 0; i < 12; i++) {
    textFont(font);
    textSize(11);
    textAlign(CENTER);
    fill(180, 180, 180);
    text(months[i], 111 + 22*i, 595);
  }

  // header
  textSize(26);
  textAlign(LEFT);
  fill(120, 120, 120);
  text('loud.fm:', 450, 100)

  // mouseover paragraph
  if (420 < mouseX & mouseX < 760 & 60 < mouseY & mouseY < 250) {
    textSize(16);
    para.html("In 2015, the year I began to stream music almost daily, I developed an unhealthy addiction to documenting and comparing my listening habits over time on Last.fm. The website could display statistics on the number of tracks I played in any given year, month, or day—however, I wanted to compare my listens throughout 2015-2018 by calendar month, and see if there was any consistent qualitative and quantitative pattern to the music I listened to over the course of a year. More than 98% of the tracks I listened to were streamed through Spotify or are available on Spotify, so I combed through these tracks' feature data in R. The track feature with the most prominent seasonal trend was loudness (Spotify defines loudness as the \"primary psychological correlate of physical strength\"), with median loudness rising during summer and winter months. ")
  }
  else {
    textSize(16);
    para.html("a mosaic of my music streaming history,<br>in quantity and loudness,<br>by calendar month. <br><br> { hover for more }")

    // legend for scrobble quantity
    textSize(11);
    textAlign(CENTER, RIGHT);
    noStroke();
    fill(230, 230, 230);
    rect(450, 558-(50/12), 20, 50/12);
    fill(180, 180, 180);
    text('50', 460, 576);
    fill(230, 230, 230);
    rect(472 + 8, 558-(775/12), 20, 775/12);
    fill(180, 180, 180);
    text('775', 482 + 8, 576);
    fill(230, 230, 230);
    rect(494 + 16, 558-(1500/12), 20, 1500/12);
    fill(180, 180, 180);
    text('1500', 504 + 16, 576);
    textSize(16);
    fill(120, 120, 120);
    text('scrobbles', 472 + 8 + 10, 596) // 586

    // legend for year and loudness
    fill(206, 13, 74, ((-9 + 10) / 4)*255);
    rect(450, 270, 20, 20);
    fill(200, 214, 0, ((-9 + 10) / 4)*255);
    rect(450, 292, 20, 20);
    fill(0, 158, 132, ((-9 + 10) / 4)*255);
    rect(450, 314, 20, 20);
    fill(92, 17, 228, ((-9 + 10) / 4)*255);
    rect(450, 336, 20, 20);
    //
    fill(206, 13, 74, ((-8 + 10) / 4)*255);
    rect(472, 270, 20, 20);
    fill(200, 214, 5, ((-8 + 10) / 4)*255);
    rect(472, 292, 20, 20);
    fill(0, 158, 132, ((-8 + 10) / 4)*255);
    rect(472, 314, 20, 20);
    fill(92, 17, 228, ((-8 + 10) / 4)*255);
    rect(472, 336, 20, 20);
    //
    fill(206, 13, 74, ((-7 + 10) / 4)*255);
    rect(494, 270, 20, 20);
    fill(200, 214, 5, ((-7 + 10) / 4)*255);
    rect(494, 292, 20, 20);
    fill(0, 158, 132, ((-7 + 10) / 4)*255);
    rect(494, 314, 20, 20);
    fill(92, 17, 228, ((-7 + 10) / 4)*255);
    rect(494, 336, 20, 20);
    //
    fill(206, 13, 74, ((-6 + 10) / 4)*255);
    rect(516, 270, 20, 20);
    fill(200, 214, 5, ((-6 + 10) / 4)*255);
    rect(516, 292, 20, 20);
    fill(0, 158, 132, ((-6 + 10) / 4)*255);
    rect(516, 314, 20, 20);
    fill(92, 17, 228, ((-6 + 10) / 4)*255);
    rect(516, 336, 20, 20);
    //
    fill(180, 180, 180);
    textAlign(RIGHT, CENTER);
    textSize(11);
    text('2015', 526 + 46, 280);
    text('2016', 526 + 46, 302);
    text('2017', 526 + 46, 324);
    text('2018', 526 + 46, 346);
    textSize(16);
    fill(120, 120, 120);
    text('year', 526 + 86, 311)
    // for db (loudness)
    fill(180, 180, 180);
    textAlign(CENTER, RIGHT);
    textSize(11);
    text('-9', 460, 374);
    text('-8', 482, 374);
    text('-7', 504, 374);
    text('-6', 526, 374);
    textSize(16);
    fill(120, 120, 120);
    text('median db', 493, 394);
  }




}
