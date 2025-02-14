/**
 * @desc 
 */

self.gui.draw();

var logY = window_get_height();

HLGuiDrawUtils.setVAlign(fa_bottom);

for (var i = array_length(LOG.entries) - 1; i >= 0; i --) {
	
	var entry = LOG.entries[i];
	var text = LOG.__entry_tostring(entry);
	
	draw_text_ext(0, logY, text, -1, window_get_width());
	logY -= string_height_ext(text, -1, window_get_width());
	
	if (logY <= 0) {
		break;
	}
	
}

HLGuiDrawUtils.resetVAlign();
