
/*	Thank you Drew McLellan for starting us off
	with http://24ways.org/2006/tasty-text-trimmer	*/

function TextTrimmer(value) {
	var self = this;

	this.minValue = 0;
	this.maxValue = 100;
	this.chunks = false;
	this.prevValue = 0;

	if (value >= this.maxValue) {
		this.curValue = this.maxValue;
	} else if (value < this.minValue) {
		this.curValue = this.minValue;
	} else {
		this.curValue = value;
	}

	this.slider = new K2Slider('#trimmerhandle', '#trimmertrack', {
		minimum: 0,
		maximum: 10,
		value: 10,
		onSlide: function(x) {
			self.doTrim(x * 10);
		},
		onChange: function(x) {
			self.doTrim(x * 10);
		}
	});

	jQuery('#trimmermore').click(function() {
		self.slider.setValueBy(1);
		return false;
	});

	jQuery('#trimmerless').click(function() {
		self.slider.setValueBy(-1);
		return false;
	});

	jQuery('#trimmertrim').click(function() {
		self.slider.setValue(self.minValue);
		return false;
	});

	jQuery('#trimmeruntrim').click(function() {
		self.slider.setValue(self.maxValue);
		return false;
	});
};

TextTrimmer.prototype.trimAgain = function() {
	this.loadChunks();
	this.doTrim(this.curValue);
};

TextTrimmer.prototype.loadChunks = function() {
	var everything = jQuery('#dynamic-content .entry-content');

	this.chunks = [];

	for (i=0; i<everything.length; i++) {
		this.chunks.push({
			ref: everything[i],
			html: jQuery(everything[i]).html(),
			text: jQuery.trim(jQuery(everything[i]).text())
		});
	}
};

TextTrimmer.prototype.doTrim = function(interval) {
	/* Spit out the trimmed text */
	if (!this.chunks)
		this.loadChunks();

	/* var interval = parseInt(interval); */
	this.curValue = interval;

	for (i=0; i<this.chunks.length; i++) {
		if (interval == this.maxValue) {
			jQuery(this.chunks[i].ref).html(this.chunks[i].html);
		} else if (interval == this.minValue) {
			jQuery(this.chunks[i].ref).html('');
		} else {
			var a = this.chunks[i].text.split(' ');
			a = a.slice(0, Math.round(interval * a.length / 100));
			jQuery(this.chunks[i].ref).html('<p>' + a.join(' ') + '&nbsp;[...]</p>');
		}
	}

	/* Add 'trimmed' class to <BODY> while active */
	if (this.curValue != this.maxValue) {
		jQuery('#dynamic-content').addClass("trimmed");
	} else {
		jQuery('#dynamic-content').removeClass("trimmed");
	}
};