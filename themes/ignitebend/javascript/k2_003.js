// script.aculo.us slider.js v1.7.0, Fri Jan 19 19:16:36 CET 2007

// Copyright (c) 2005, 2006 Marty Haught, Thomas Fuchs 
//
// script.aculo.us is freely distributable under the terms of an MIT-style license.
// For details, see the script.aculo.us web site: http://script.aculo.us/

function K2Slider(handle, track, options) {
	var self = this;

	this.handle  = jQuery(handle);
    this.track   = jQuery(track);
    this.options = options || {};

    this.value     = this.options.value || 0;

    this.maximum   = this.options.maximum || 1;
    this.minimum   = this.options.minimum || 0;

    this.trackLength  = this.track.width();
    this.handleLength = this.handle.width();
	this.handle.css('position', 'absolute');

    this.active   = false;
    this.dragging = false;

    this.setValue(this.value);
   
    this.handle.mousedown(function(event) {
		self.active = true;

        var pointer	= self.pointerX(event);
		var offset	= self.track.offset();

		self.setValue(
			self.translateToValue(
				pointer-offset.left-(self.handleLength/2)
          	)
		);

		var offset = self.handle.offset();
		self.offsetX = (pointer - offset.left);
	});

	this.track.mousedown(function(event) {
		var offset	= self.track.offset();
        var pointer	= self.pointerX(event);

		self.setValue(
			self.translateToValue(
				pointer-offset.left-(self.handleLength/2)
          	)
		);
	});

	jQuery(document).mouseup(function(event){
		if (self.active && self.dragging) {
			self.active = false;
			self.dragging = false;

			self.updateFinished(self);
		}
		self.active = false;
		self.dragging = false;
	});

	jQuery(document).mousemove(function(event){
		if (self.active) {
			if (!self.dragging) self.dragging = true;

			self.draw(event);

			// fix AppleWebKit rendering
			if (navigator.appVersion.indexOf('AppleWebKit')>0) window.scrollBy(0,0);
		}
	});

	this.initialized = true;
};

K2Slider.prototype.getNearestValue = function(value) {
	if (value > this.maximum) return this.maximum;
	if (value < this.minimum) return this.minimum;
	return value;
};

K2Slider.prototype.setValue = function(value) {
	this.value = this.getNearestValue(value);

	this.handle.css('left', this.translateToPx(this.value));
   
	if (!this.dragging || !this.event) this.updateFinished(this);
};

K2Slider.prototype.setValueBy = function(delta) {
	this.setValue(this.value + delta);
};

K2Slider.prototype.translateToPx = function(value) {
	return Math.round(
		((this.trackLength-this.handleLength)/(this.maximum-this.minimum)) * 
		(value - this.minimum)) + "px";
};

K2Slider.prototype.translateToValue = function(offset) {
	return Math.round(
		((offset/(this.trackLength-this.handleLength) * 
		(this.maximum-this.minimum)) + this.minimum));
};

K2Slider.prototype.draw = function(event) {
	var pointer = this.pointerX(event);
	var offset	= this.track.offset();
	pointer		-= this.offsetX + offset.left;

    this.event = event;
	this.setValue( this.translateToValue(pointer) );

	if (this.initialized && this.options.onSlide)
		this.options.onSlide(this.value);
};

K2Slider.prototype.updateFinished = function(self) {
	if (self.initialized && self.options.onChange) 
		self.options.onChange(self.value);

	self.event = null;
};

K2Slider.prototype.pointerX = function(event) {
	return event.pageX || (event.clientX +
		(document.documentElement.scrollLeft || document.body.scrollLeft));
};

K2Slider.prototype.isLeftClick = function(event) {
	return (((event.which) && (event.which == 1)) ||
		((event.button) && (event.button == 1)));
};
