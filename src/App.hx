class App extends hxd.App {
	static function main() {
		trace("Starting demo app");
		new App();
	}

	override function init() {
		hxd.Res.initEmbed();

		var font = hxd.Res.Pacifico_sdf.toSdfFont(60, Alpha);
		var text = new h2d.Text(font, s2d);
		text.text = "Hello world!";
		text.textAlign = Center;
		text.x = s2d.width / 2;
		text.y = s2d.height / 2 - text.textHeight;
	}
}
