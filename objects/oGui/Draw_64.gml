/**
 * @desc 
 */

self.gui.draw();

var logY = window_get_height();

HLGuiDrawUtils.setVAlign(fa_bottom);

for (var i = array_length(LOG.entries) - 1; i >= 0; i --) {
	
	var entry = LOG.entries[i];
	var severity = entry[LogEntryIndex.Severity];
	var colour = c_white;
	var text = LOG.__entry_tostring(entry);
	
	switch (severity) {
		case LogSeverity.Debug: colour = c_grey; break;
		case LogSeverity.Info: colour = c_white; break;
		case LogSeverity.Warn: colour = c_yellow; break;
		case LogSeverity.Error: colour = c_red; break;
		case LogSeverity.Fatal: colour = c_maroon; break;
	}
	
	HLGuiDrawUtils.setColour(colour);
	draw_text_ext(0, logY, text, -1, window_get_width());
	HLGuiDrawUtils.resetColour();
	
	logY -= string_height_ext(text, -1, window_get_width());
	
	if (logY <= 0) {
		break;
	}
	
}

HLGuiDrawUtils.resetVAlign();
