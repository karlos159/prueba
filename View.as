package com.edux
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.MP3Loader;
	import com.greensock.loading.SWFLoader;
	import com.greensock.loading.VideoLoader;
	import com.edux.control.TimeLine;
	import com.edux.event.NavigationEvent;
	import com.edux.ui.TimeLineBar;
	import com.edux.ui.button.SimpleButton;
	import com.edux.util.Const;
	import com.edux.util.Model;
	import com.edux.util.Tools;
	import flash.display.Sprite;
	import com.greensock.loading.LoaderMax;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Back;
	import flash.events.MouseEvent;
	import com.edux.control.Animation;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.system.Security;
	
	public class View extends MovieClip
	{
		public var tl:TimeLine;
		private var contador:int = 0;
		private var sound:MP3Loader;
		private var video:VideoLoader;
		
		public function View()
		{
			stop();
			if(stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			gotoAndStop(1);
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			Security.allowDomain("*");

			tl = new TimeLine(this as MovieClip);
			Model.getInstance().tl = tl;
			tl.onCompleteCallBack = onComplete;
			
			//validacion para probar la pantalla sola
			
			if (Model.getInstance().main == null) {
				if(this.getChildByName("timebar")) Model.getInstance().timebar = this.getChildByName("timebar") as TimeLineBar;
				Model.getInstance().productionMode = false;
			}else{
				if(this.getChildByName("timebar")) this.getChildByName("timebar").visible = false;
				Model.getInstance().productionMode = true;
				addEventListener(Event.REMOVED_FROM_STAGE, removed);
			}
			
			if(this.totalFrames > 2) gotoAndPlay(2);
			else gotoAndStop(2);
			
			if (Model.getInstance().productionMode && tl) {
				//main("navigation").btnNext.visible = true;
				main("navigation").btnNext.disabled = false;
				main("navigation").btnNext.alpha = 1;
			}
		}
		
		private function removed(e:Event):void {
			if (sound != null) sound.unload();
			if (video != null) video.unload();
			
			tl.clear();
			removeEventListener(Event.REMOVED_FROM_STAGE, removed);
			removeChildrens(this);
		}
		
		private function removeChildrens(container:MovieClip):void {
			while (container.numChildren > 0) {
				if (container.getChildAt(0) is MovieClip) {
					var mc:MovieClip = container.getChildAt(0) as MovieClip;
					container.removeChild(mc);
					if (mc.numChildren > 0) {
						contador++;
						//trace(contador, mc.name, mc.numChildren);
						removeChildrens(container);
					}
				}else {
					container.removeChildAt(0);
				}
			}
		}
		
		private function onComplete():void{
			if(Model.getInstance().productionMode){
				//main("navigation").btnNext.disabled = false;
				//main("navigation").btnNext.alpha = 1;
			}else {
				trace("Terminó tl");
			}
		}

		private function main(name:String):MovieClip{
			if(Model.getInstance().productionMode){
				var mc:MovieClip = Model.getInstance().main.getChildByName(name) as MovieClip;
				if(mc != null) return mc;
				else return new MovieClip();
			}
			return new MovieClip();
		}

		private function addMedia(name:String, content:MovieClip = null, onComplete:Function = null):void{
			var extension:String = Tools.getExtensionOf(name);
			switch(extension){
				case 'swf':{ loadSWF(name, content); break;}
				case 'flv':{ loadVideo(name, content, onComplete); break;}
				case 'f4v':{ loadVideo(name, content); break;}
				case 'mp4': { loadVideo(name, content); break; }
				case 'mp3': { loadMp3(name); break; }
			}
		}
		
		private function loadMp3(name:String):void {
			if (sound != null) sound.unload();
			
			sound = LoaderMax.getLoader(name) as MP3Loader;
			if (sound == null || sound.duration == 0) {
				var source:String = Const.SRC_AUDIO + name; 
				sound = new MP3Loader(source, {name:name, autoPlay:false, onComplete:onCompleteSound});
				sound.load();
			}else{
				sound.playSound();
			}
			
			function onCompleteSound(e:LoaderEvent):void {
				e.target.playSound();
			}
		}
		
		private function loadVideo(name:String, content:MovieClip, onComplete:Function = null){
			if (video != null) {
				video.unload();
				video = null;
			}
			
			video = LoaderMax.getLoader(name) as VideoLoader;
			
			if (video == null || video.duration == 200) {
				var source:String = Const.SRC_VIDEO + name; 
				video = new VideoLoader(source, {name:name, autoPlay:false, onComplete:onCompleteVideo});
				video.load();
			}else{
				if (onComplete != null) video.addEventListener(VideoLoader.VIDEO_COMPLETE, onComplete);
				content.addChild(video.content);
				content.width = 432.95;
				content.height = 328;
				video.playVideo();
			}
			
			function onCompleteVideo(e:LoaderEvent):void {
				if (onComplete != null) video.addEventListener(VideoLoader.VIDEO_COMPLETE, onComplete);
				content.addChild(video.content);
				content.width = 432.95;
				content.height = 328;
				e.target.playVideo();
			}
		}
		
		private function loadSWF(name:String, content:MovieClip){
			var loader:SWFLoader = new SWFLoader(Const.SRC_SWF + name, {autoPlay:false, onComplete:onCompleteSWF});
			loader.load();
			
			function onCompleteSWF(e:LoaderEvent):void{
				content.addChild(e.target.content);
			}
		}
		
		private function disableTimeBar():void{ Model.getInstance().main.timebar.disable = true;}
		private function enableTimeBar():void{ Model.getInstance().main.timebar.disable = false;}
	}
}