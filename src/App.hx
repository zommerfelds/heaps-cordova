import haxe.Timer;

class App extends hxd.App {
	var octopus:h2d.Object;
	var octopus2:h2d.SpriteBatch.BatchElement;
	var statusText:h2d.Text;
	var draw:h2d.Graphics;
	var world:h2d.Object;

	final start = Timer.stamp();

	static function main() {
		trace("Starting demo app");
		new App();
	}

	override function init() {
		hxd.Res.initEmbed();

		final font = hxd.Res.Pacifico_sdf.toSdfFont(Std.int(s2d.width * 0.1), Alpha);
		final text = new h2d.Text(font, s2d);
		text.text = "Hello world!";
		text.textAlign = Center;
		text.x = s2d.width / 2;
		text.y = s2d.height * 0.2 - text.textHeight;

		world = new h2d.Object(s2d);

		statusText = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
		final s = s2d.width * 0.005;
		statusText.scale(s);
		statusText.x = (s2d.width - statusText.calcTextWidth("x = ###") * s) / 2;
		statusText.y = s2d.height * 0.8;

		draw = new h2d.Graphics(world);
		draw.y = s2d.height * 0.3;

		final spriteSheet = hxd.Res.octopus_sprite_sheet.toTile();
		final frameSize = 32;
		final frame0 = spriteSheet.sub(0 * frameSize, 0 * frameSize, frameSize, frameSize, -frameSize / 2, -frameSize / 2);
		final frame1 = spriteSheet.sub(1 * frameSize, 0 * frameSize, frameSize, frameSize, -frameSize / 2, -frameSize / 2);
		final frame2 = spriteSheet.sub(2 * frameSize, 0 * frameSize, frameSize, frameSize, -frameSize / 2, -frameSize / 2);
		final frame3 = spriteSheet.sub(3 * frameSize - 1, 0 * frameSize, frameSize, frameSize, -frameSize / 2, -frameSize / 2);

		final anim = new h2d.Anim([frame0, frame1, frame2, frame3], 10, world);
		anim.scale(s2d.width / frameSize * 0.4);
		anim.y = s2d.height * 0.72;
		octopus = anim;

		final batch = new h2d.SpriteBatch(frame0, world);
		batch.hasRotationScale = true;
		final batchElem = batch.alloc(frame0);
		batchElem.y = s2d.height * 0.53;
		batchElem.scale = s2d.width / frameSize * 0.4;
		octopus2 = batchElem;
	}

	override function update(timeStep:Float) {
		final now = Timer.stamp();
		final t = (now - start);

		final velocityX = 500.0;
		octopus.x = s2d.width / 2 + t * velocityX;
		octopus2.x = s2d.width / 2 + t * velocityX;
		world.x = -t * velocityX;
		statusText.text = "x = " + Std.int(octopus.x);

		final blockDistance = 50.0;
		final border = 2.0;

		final firstBlock = Std.int((-world.x) / blockDistance) * blockDistance;
		final lastBlock = Std.int((-world.x + s2d.width) / blockDistance) * blockDistance;

		draw.clear();

		var x = firstBlock;
		while (x < lastBlock + 1.0) {
			final r = Std.int((x % s2d.width) / s2d.width * 255);
			// WARNING: This is an example that doesn't work well on mobile phones,
			// because floating point precision is low and the border width changes the
			// further you go from the origin.
			draw.beginFill(0xff000000 + (r << 16));
			draw.drawRect(x, 0, blockDistance - border, s2d.height / 8);
			draw.beginFill(0xffffffff);
			draw.drawRect(x + blockDistance - border, 0, border, s2d.height / 8);
			x += blockDistance;
		}
	}
}
