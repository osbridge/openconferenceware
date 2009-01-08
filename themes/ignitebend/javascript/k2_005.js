
function LiveSearch(url, searchprompt) {
	var self = this;

	this.url = url;
	this.searchPrompt = searchprompt;
	this.input = jQuery('input#s');

	// Hide the submit button
	jQuery('#searchform input[@type=submit]').hide();

	// Insert reset and loading elements
	this.input.after('<span id="searchreset"></span><span id="searchload"></span>');
	this.reset = jQuery('#searchreset');
	this.loading = jQuery('#searchload');

	this.input.addClass('livesearch').val(this.searchPrompt)
	
	this.loading.hide();
	this.reset.show().fadeTo('fast', 0.3);

	// Bind events to the search input
	this.input
		.focus(function() {
			if (self.input.val() == self.searchPrompt) {
				self.input.val('');
			}
		})
		.blur(function() {
			if (self.input.val() == '') {
				self.input.val(self.searchPrompt);
			}
		})
		.keyup(function(event) {
			var code = event.keyCode;

			if (self.input.val() == '') {
				return false;
			} else if (code == 27) {
				self.input.val('');
			} else if (code != 13) {
				if (self.timer) {
					clearTimeout(self.timer);
				}
				self.timer = setTimeout(function(){ self.doSearch(self); }, 500);
			}
		});
};

LiveSearch.prototype.doSearch = function(self) {
	if (self.input.val() == self.prevSearch) return;

	self.reset.fadeTo('fast', 0.3);
	self.loading.fadeIn('fast');

	if (!self.active) {
		self.active = true;

		if (typeof K2.RollingArchives != 'undefined' && K2.RollingArchives.saveState) {
			K2.RollingArchives.saveState();
		}
	}

	self.prevSearch = self.input.val();

	K2.ajaxGet(self.url, self.input.serialize() + '&k2dynamic=init',
		function(data) {
			jQuery('#current-content').hide();
			jQuery('#dynamic-content').show().html(data);

			self.loading.fadeOut('fast');

			self.reset.click(function(){
				self.resetSearch(self);
			}).fadeTo('fast', 1.0).css('cursor', 'pointer');
		}
	);
};

LiveSearch.prototype.resetSearch = function(self) {
	self.active = false;
	self.prevSearch = '';

	self.input.val(self.searchPrompt);

	self.reset.unbind('click').fadeTo('fast', 0.3).css('cursor', 'default');

	if ( jQuery('#current-content').length ) {
		jQuery('#dynamic-content').hide().html('');
		jQuery('#current-content').show();
	}

	if (typeof K2.RollingArchives != 'undefined' && K2.RollingArchives.restoreState) {
		K2.RollingArchives.restoreState();
	}
};
