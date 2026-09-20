package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.util.FlxColor;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.display.StageScaleMode;
import meta.states.*;
import meta.data.*;
import meta.MacroData;
import meta.backend.FPSCounter;

class Main extends Sprite
{
	var gameWidth:Int = 1280;
	var gameHeight:Int = 720;
	var initialState:Class<FlxState> = InitState;
	var zoom:Float = -1;
	var framerate:Int = 60;
	var skipSplash:Bool = false;
	var startFullscreen:Bool = false;

	public static var fpsVar:FPSCounter;
	public static var compilationInformation:TextField;

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
	}

	public static function setScaleMode(scale:String)
	{
		switch (scale)
		{
			default:
				Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
			case 'EXACT_FIT':
				Lib.current.stage.scaleMode = StageScaleMode.EXACT_FIT;
			case 'NO_BORDER':
				Lib.current.stage.scaleMode = StageScaleMode.NO_BORDER;
			case 'SHOW_ALL':
				Lib.current.stage.scaleMode = StageScaleMode.SHOW_ALL;
		}
	}

	private function setupGame():Void
	{
		#if mobile
		mobile.backend.StorageSystem.init();
		lime.system.System.allowScreenTimeout = false;
		#end

		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		ClientPrefs.loadDefaultKeys();
		addChild(new FNFGame(gameWidth, gameHeight, initialState, #if (flixel < "5.0.0") zoom, #end framerate, framerate, skipSplash, startFullscreen));

		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;

		#if !mobile
		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		fpsVar.visible = ClientPrefs.data.showFPS;
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		var compTime = MacroData.getDate();
		var time = Date.now().toString();
		var compUSR = MacroData.getUSR();
		var usrName:String = "unknown";

		#if sys
		var env = Sys.environment();

		if (env.exists("USERNAME"))
			usrName = env["USERNAME"];
		else if (env.exists("USER"))
			usrName = env["USER"];
		#end

		compilationInformation = new TextField();
		compilationInformation.y = (FlxG.height / 4) * 3;
		compilationInformation.defaultTextFormat = new TextFormat("_sans", 24, FlxColor.fromRGB(255, 125, 125));
		compilationInformation.text = 'nice! Build Compilation Date: ${compTime}\nnice! Build open date: ${time}\nnice! Build Compiled by: nice! ${compUSR}\nI know who you are. ${usrName}';
		compilationInformation.multiline = true;
		compilationInformation.selectable = false;
		compilationInformation.autoSize = LEFT;
		compilationInformation.mouseEnabled = false;
		compilationInformation.alpha = 0.675;
	}

	public static function resetSpriteCache(sprite:Sprite):Void
	{
		@:privateAccess
		{
			sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}
}

class FNFGame extends FlxGame
{
	private static function crashGame()
	{
		null.draw();
	}

	override function create(_):Void
	{
		try
			super.create(_)
		catch (e)
			onCrash(e);
	}

	override function onFocus(_):Void
	{
		try
			super.onFocus(_)
		catch (e)
			onCrash(e);
	}

	override function onFocusLost(_):Void
	{
		try
			super.onFocusLost(_)
		catch (e)
			onCrash(e);
	}

	override function onEnterFrame(_):Void
	{
		try
			super.onEnterFrame(_)
		catch (e)
			onCrash(e);
	}

	override function update():Void
	{
		#if CRASH_TEST
		if (FlxG.keys.justPressed.F9)
			crashGame();
		#end

		try
			super.update()
		catch (e)
			onCrash(e);
	}

	override function draw():Void
	{
		try
			super.draw()
		catch (e)
			onCrash(e);
	}

	private final function onCrash(e:haxe.Exception):Void
	{
		#if !debug
		var emsg:String = "";

		for (stackItem in haxe.CallStack.exceptionStack(true))
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					emsg += file + " (line " + line + ")\n";
				default:
			}
		}

		FlxG.switchState(new meta.states.substate.CrashReportSubstate(FlxG.state, emsg, e.message));
		#end
	}
}
