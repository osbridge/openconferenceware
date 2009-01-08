
function RollingArchives(url, pagetext) {
	this.url = url;
	this.pageText = pagetext;
	this.active = false;
};

RollingArchives.prototype.setState = function(pagenumber, pagecount, query, pagedates) {
	var self = this;

	this.pageNumber = pagenumber;
	this.pageCount = pagecount;
	this.query = query;
	this.pageDates = pagedates;

	if ( this.validatePage(pagenumber) ) {
		jQuery('#rollingarchives').show();

		jQuery('#rollload').hide();
		jQuery('#rollhover').hide();

		// Setup the page slider
		this.pageSlider = new K2Slider('#pagehandle', '#pagetrack', {
			minimum: 1,
			maximum: self.pageCount,
			value: self.pageCount - self.pageNumber + 1,
			onSlide: function(value) {
				jQuery('#rollhover').show();
				self.updatePageText( self.pageCount - value + 1);
			},
			onChange: function(value) {
				self.updatePageText( self.pageCount - value + 1);
				self.gotoPage( self.pageCount - value + 1 );
			}
		});

		// Add click events
		jQuery('#rollnext').click(function() {
			self.pageSlider.setValueBy(1);
			return false;
		});
		jQuery('#rollprevious').click(function() {
			self.pageSlider.setValueBy(-1);
			return false;
		});

		this.updatePageText( this.pageNumber );

		this.trimmer = new TextTrimmer(100);
		this.active = true;
	} else {
		jQuery('#rollingarchives').hide();
	}
};


RollingArchives.prototype.saveState = function() {
	this.prevQuery = this.query;
};


RollingArchives.prototype.restoreState = function() {
	if (this.prevQuery != null) {
		var url = this.url.replace('theloop', 'rollingarchive');
		var query = jQuery.extend(this.prevQuery, { k2dynamic: 'init' });

		K2.ajaxGet(url, query,
			function(data) {
				jQuery('#dynamic-content').html(data);
			}
		);
	}
};


RollingArchives.prototype.updatePageText = function(page) {
	jQuery('#rollpages').html(
		(this.pageText.replace('%1$d', page)).replace('%2$d', this.pageCount)
	);
	jQuery('#rolldates').html(this.pageDates[page - 1]);
};


RollingArchives.prototype.validatePage = function(newpage) {
	if (this.pageCount > 1) {
		if (newpage >= this.pageCount) {
			jQuery('#dynamic-content').removeClass('onepageonly firstpage nthpage').addClass('lastpage');
			return this.pageCount;

		} else if (newpage <= 1) {
			jQuery('#dynamic-content').removeClass('onepageonly nthpage lastpage').addClass('firstpage');
			return 1;

		} else {
			jQuery('#dynamic-content').removeClass('onepageonly firstpage lastpage').addClass('nthpage');
			return newpage;
		}
	}

	jQuery('#dynamic-content').removeClass('firstpage nthpage lastpage').addClass('onepageonly');

	return 0;
};


RollingArchives.prototype.gotoPage = function(newpage) {
	var self = this;
	var page = this.validatePage(newpage);

	if ( (page != this.pageNumber) && (page > 0) ) {
		this.pageNumber = page;

		jQuery('#rollload').fadeIn('fast');
		jQuery.extend(this.query, { paged: this.pageNumber, k2dynamic: 1 });

		K2.ajaxGet(this.url, this.query,
			function(data) {

				if (self.pageNumber == 1) {
					jQuery('html,body').animate({
						scrollTop: jQuery('body').offset().top - 1
					}, 1000);
				} else {
					jQuery('html,body').animate({
						scrollTop: jQuery('#dynamic-content').offset().top - 1
					}, 1000);
				}
				
				jQuery('#rollhover').fadeOut('slow');
				jQuery('#rollload').fadeOut('fast');
				jQuery('#rollingcontent').html(data);
				
				self.trimmer.trimAgain();
			}
		);
	}

	if (page == 1)
		this.trimmer.slider.setValue(100);
};


jQuery(window).scroll(function(){
	if (typeof K2.RollingArchives != 'undefined' && K2.RollingArchives.active) {
		smartPosition('#dynamic-content');
	}
});
