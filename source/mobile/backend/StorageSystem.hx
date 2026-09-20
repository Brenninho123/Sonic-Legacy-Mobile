package mobile.backend;

#if android
import extension.androidtools.Permissions as AndroidPermissions;
import extension.androidtools.content.Context as AndroidContext;
import extension.androidtools.os.Build.VERSION as AndroidVersion;
#end
import haxe.io.Path;
import sys.FileSystem;

class StorageSystem
{
	public static var initialized(default, null):Bool = false;

	static final requiredFolders:Array<String> = ['mods', 'assets'];

	public static function getRootDirectory():String
	{
		#if android
		return Path.addTrailingSlash(AndroidContext.getExternalFilesDir());
		#else
		return Path.addTrailingSlash(Sys.getCwd());
		#end
	}

	public static function getModsDirectory():String
	{
		return getRootDirectory() + 'mods/';
	}

	public static function requestPermissions():Void
	{
		#if android
		if (AndroidVersion.SDK_INT < 33)
			AndroidPermissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);
		#end
	}

	public static function prepareDirectories():Bool
	{
		var root:String = getRootDirectory();

		try
		{
			for (folder in requiredFolders)
			{
				var path:String = root + folder;

				if (!FileSystem.exists(path))
					FileSystem.createDirectory(path);
			}

			Sys.setCwd(root);
			return true;
		}
		catch (e:Dynamic)
		{
			return false;
		}
	}

	public static function init():Bool
	{
		if (initialized)
			return true;

		requestPermissions();
		initialized = prepareDirectories();

		return initialized;
	}
}
