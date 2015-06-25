package com.edux
{
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.CSSLoader;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.MP3Loader;
	import com.greensock.loading.SWFLoader;
	import com.greensock.loading.VideoLoader;
	import com.greensock.loading.XMLLoader;
	import com.edux.control.CVSCORM;
	import com.edux.control.TimeLine;
	import com.edux.entity.MenuItemEntity;
	import com.edux.event.NavigationEvent;
	import com.edux.integration.Analytics;
	import com.edux.integration.Scorm;
	import com.edux.ui.Menu;
	import com.edux.ui.TimeLineBar;
	import com.edux.ui.TottusIndice;
	import com.edux.util.Const;
	import com.edux.util.Model;
	import com.edux.util.Tools;
	import flash.events.MouseEvent;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.media.SoundMixer;
	import flash.system.Security;
	import flash.external.ExternalInterface;
	import com.edux.entity.CVEntity;
	
	public class Main extends MovieClip
	{
		//public static const TRANSITION_SLIDE:String = "slide";
		
		public var timebar:TimeLineBar;
		public var content:MovieClip;
		public var preloader:MovieClip;
		public var navigation:MovieClip;
		public var mensaje:MovieClip;
		public var menu:Menu;
		//public var indice:TottusIndice;
		
		//dimensiones
		public var appWidth:Number = 750;
		public var appHeight:Number = 480;
		//transicion
		public var transition:String = "";
		
		public var loader:LoaderMax;
		private var views:Vector.<MenuItemEntity>;
		private var menuList:Vector.<MenuItemEntity>;
		private var indexView:int = 0;
		private var lastIndexView:int = 0;
		private var swfLoader:SWFLoader;
		private var canNavigate:Boolean = false;
		private var totalViews:Array;
		
		//SCORM
		private var maxScore:int = 0;
		private var score:Number = 0;
		
		private var useTimeline:Boolean = true;
		private var useMenu:Boolean = false;
		
		private var maxViewed:int = 0;
		
		public function Main() {
			if(stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//Model.getInstance().cv = new CVEntity();
			
			totalViews = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
			trace(totalViews.length);
			
			Security.allowDomain("*");
			
			if(Model.getInstance().tl != null) Model.getInstance().tl.clear();
			else trace("timeline vacio");

			Model.getInstance().main = this as MovieClip;
			Model.getInstance().timebar = timebar;
			
			if(mensaje) mensaje.visible = false;
			if(timebar) timebar.visible = false;
			if (menu) menu.visible = false;
			mensaje.visible = false;
				
			//preloader.stop();
			Tools.call(Const.SRC_CONFIG, null, onCompleteConfig);  
		}
		
		private function onCompleteConfig(e:Event):void{
			//trace(e.target.data);
			var xml:XML = new XML(e.target.data);
			views = new Vector.<MenuItemEntity>();
			menuList = new Vector.<MenuItemEntity>();
			loader = new LoaderMax({maxConnections:4, onProgress:onProgressLoader, onComplete:onCompleteLoader, onError:onError});
			loader.skipFailed = true;

			for each(var item:XML in xml.navigation.item){
				menuList.push(loadMenuItems(item));
			}

			//cargamos la prioridad 1
			for(var j:int = 0; j < xml.assets.pack.(@priority == "1").file.length(); j++){
				
				var file:String = xml.assets.pack.(@priority == "1").file[j].@name;
				var extension:String = Tools.getExtensionOf(file);
				
				switch(extension){
					case "swf":{	loader.append(new SWFLoader(Const.SRC_SWF + file, {name:file, autoPlay:false, autoDispose:false}));	break;}
					case "mp3": {	loader.append(new MP3Loader(Const.SRC_AUDIO + file, { name:file, autoPlay:false, autoDispose:false } ));	break; }
					case "flv":{	loader.append(new VideoLoader(Const.SRC_VIDEO + file, {name:file, autoPlay:false, autoDispose:false}));	break;}
					case "mp4":{	loader.append(new VideoLoader(Const.SRC_VIDEO + file, {name:file, autoPlay:false, autoDispose:false}));	break;}
					case "f4v":{	loader.append(new VideoLoader(Const.SRC_VIDEO + file, {name:file, autoPlay:false, autoDispose:false}));	break;}
					case "png":{	loader.append(new ImageLoader(Const.SRC_IMAGE + file, {name:file, autoPlay:false, autoDispose:false}));	break;}
					case "jpg":{	loader.append(new ImageLoader(Const.SRC_IMAGE + file, {name:file, autoPlay:false, autoDispose:false}));	break;}
					case "jpeg":{	loader.append(new ImageLoader(Const.SRC_IMAGE + file, {name:file, autoPlay:false, autoDispose:false}));	break;}
					case "css":{	loader.append(new CSSLoader(Const.SRC_CSS + file, {name:file, autoPlay:false, autoDispose:false}));	break;}
					case "xml":{	loader.append(new XMLLoader(Const.SRC_XML + file, {name:file, autoPlay:false, autoDispose:false}));	break;}
				}
			}
			
			if(menu) menu.init(menuList);
			
			useTimeline = (xml.config.timeline.@enabled == "true")? true:false;
			useMenu = (xml.config.menu.@enabled == "true")? true:false;
			
			if(timebar) timebar.visible = useTimeline;
			if(menu) menu.visible = useMenu;
			
			maxScore = int(xml.config.scorm.maxScore);
			Scorm.config(new XML(xml.config.scorm));
			loader.load();
		}
		
		private function onSuccessScorm(result:Boolean):void {
			if (result) {
				
				if (Model.getInstance().useScorm) {
					if(Scorm.get(Const.LOCATION) != null)maxViewed = int(Scorm.get(Const.LOCATION));
					
					if (maxViewed > 0) {
						//preCopia.visible = false;
						mensaje.visible = true;
						mensaje.btnSi.onClick = onClickMensaje;
						mensaje.btnNo.onClick = onClickMensaje;
						addListeners();
						//dispatchEvent(new NavigationEvent(NavigationEvent.FIRST_VIEW));
					}else {
						addListeners();
						dispatchEvent(new NavigationEvent(NavigationEvent.FIRST_VIEW));
					}
				}else {
					addListeners();
					dispatchEvent(new NavigationEvent(NavigationEvent.FIRST_VIEW));
				}
				
			}else{
				
				addListeners();
				dispatchEvent(new NavigationEvent(NavigationEvent.FIRST_VIEW));
				
			}
		}
		
		private function onClickMensaje(e:MouseEvent):void {
			addListeners();
			//indice.refresh(maxViewed);
			if (e.currentTarget.name == "btnSi") {
				var event:NavigationEvent = new NavigationEvent(NavigationEvent.CUSTOM);
				event.nextView = maxViewed;
				//CVSCORM.load();
				dispatchEvent(event);
			}else if (e.currentTarget.name == "btnNo") {
				dispatchEvent(new NavigationEvent(NavigationEvent.FIRST_VIEW));
			}
			mensaje.visible = false;
		}
		
		private function onFailScorm():void {
			trace("onFailScorm");
		}
		
		private function loadMenuItems(xmlItem:XML):MenuItemEntity{
			for each(var child:XML in xmlItem){
				var item:MenuItemEntity = new MenuItemEntity();
				item.name = child.@name;
				item.type = child.@type;
				if(child.children().length() > 0){
					item.childs = new Vector.<MenuItemEntity>();
					for each(var xmlChild:XML in xmlItem.children()){
						item.childs.push(loadMenuItems(xmlChild));
					}
				}else{
					item.id = child.@id;
					item.url = child.@url;
					item.viewed = false;
					views.push(item);
					loader.append(new SWFLoader(Const.SRC_SWF + item.url, {autoPlay:false}));
				}
				return item;
			}
			return null;
		}
		
		private function onProgressLoader(e:LoaderEvent):void{
			if (preloader.txtPorcentaje) {
				trace(int(e.target.progress * 100) + '%');
				preloader.txtPorcentaje.text = int(e.target.progress * 100) + '%';
				//preloader.barra.barra_carga.scaleX = e.target.progress;
			}
			if(preloader.totalFrames == 100) preloader.gotoAndStop(int(e.target.progress * 100));
		}
		
		private function onCompleteLoader(e:LoaderEvent):void{
			preloader.visible = false;
			canNavigate = true;
			Scorm.connect(onSuccessScorm, onFailScorm);
			//dispatchEvent(new NavigationEvent(NavigationEvent.FIRST_VIEW));
		}
		
		private function onError(e:LoaderEvent):void{
			trace("ERROR");
		}
		
		private function addListeners():void{
			this.addEventListener(NavigationEvent.NEXT_VIEW, onChangeView);
			this.addEventListener(NavigationEvent.PREV_VIEW, onChangeView);
			this.addEventListener(NavigationEvent.FIRST_VIEW, onChangeView);
			this.addEventListener(NavigationEvent.LAST_VIEW, onChangeView);
			this.addEventListener(NavigationEvent.REGFRESH, onChangeView);
			this.addEventListener(NavigationEvent.CUSTOM, onChangeView);
		}
		
		private function onChangeView(e:NavigationEvent):void{
			if(canNavigate){
				if (swfLoader != null) swfLoader.unload();
				
				lastIndexView = indexView;
			
				//NavigationEvent.REGFRESH no necesita un case ya que carga la misma vista
				switch(e.type){
					case NavigationEvent.NEXT_VIEW:		{ if(indexView < views.length) indexView++; break; }
					case NavigationEvent.PREV_VIEW:		{ if(indexView > 0) indexView--; break; }
					case NavigationEvent.FIRST_VIEW:	{ indexView = 0; break; }
					case NavigationEvent.LAST_VIEW:		{ indexView = views.length - 1; break;}
					case NavigationEvent.CUSTOM:		{ indexView = e.nextView; break; }
				}
				
				//mostrar u ocultar botones si se encuentra en la primera o ultima pantalla
				if(indexView == 0){
					if(navigation.btnPrev) navigation.btnPrev.visible = false;
					if(navigation.btnFirst) navigation.btnFirst.visible = false;
				}else{
					if(navigation.btnPrev) navigation.btnPrev.visible = true;
					if(navigation.btnFirst) navigation.btnFirst.visible = true;
				} 

				if(indexView == views.length - 1){
					if(navigation.btnNext) navigation.btnNext.visible = false;
					if(navigation.btnLast) navigation.btnLast.visible = false;
				}else{
					if(navigation.btnNext) navigation.btnNext.visible = true;
					if(navigation.btnLast) navigation.btnLast.visible = true;
				}
				
				trace("Siguiente Vista:", indexView);
				swfLoader = LoaderMax.getLoader(views[indexView].url) as SWFLoader;
				if(swfLoader == null){
					swfLoader = new SWFLoader(Const.SRC_SWF + views[indexView].url,{onComplete:onCompleteView});
					swfLoader.load();
				}else{
					onCompleteView();
				}
				
				canNavigate = false;
				navigation.alpha = 0.5;
			}
		}
		
		private function onCompleteView(e:LoaderEvent = null):void{
			
			SoundMixer.stopAll();
			navigation.txtView.text = indexView + "/" + (views.length - 1);
			navigation.txtView1.text = navigation.txtView.text;
			trace(navigation.txtView1.text);

			showElements();
			
			Tools.clean(content);
			
			content.addChild(swfLoader.rawContent as MovieClip);
			canNavigate = true;
			navigation.alpha = 1;
			
			
			if (indexView > maxViewed) {
				maxViewed = indexView;
				//Calcular Score del SCORM
				var pointsPerView:Number = Number(maxScore) / (views.length-1);
				score = maxViewed * pointsPerView;
				var scorep:int=int(score);
				if (Model.getInstance().useScorm) {
					Scorm.set(Const.SCORE, String(scorep));
					Scorm.set(Const.LOCATION, maxViewed.toString());
					txtNumber.text = maxViewed.toString();
					trace(scorep);
					if (indexView == views.length - 1) {
						Scorm.set(Const.STATUS, "passed");
					}else {
						Scorm.set(Const.STATUS, "incomplete");
					}
					
				}
				//indice.refresh(maxViewed);
			}
			
			navigation.btnNext.gotoAndStop(1);
			navigation.btnPrev.gotoAndStop(1);
		}
		
		private function showElements():void{
			for(var i:int = 0; i < numChildren; i++){
				if(getChildAt(i) is MovieClip){
					var child:MovieClip = getChildAt(i) as MovieClip;
					if (child.name != "preloader") {
						if (child.name == "timebar") {
							timebar.visible = useTimeline;
						}else if (child.name == "menu") {
							menu.visible = useMenu;
						}else if (child.name == "ayuda") {
							child.visible = false;
						}else if (child.name == "indice") {
							child.visible = false;
						}else if (child.name == "recursos") {
							child.visible = false;
						}else if (child.name == "mensaje") {
							child.visible = false;
						}else{
							child.visible = true;
						}
					}
				}
			}
			//preCopia.visible = false;
			timebar.disable = false;
		}
	}
}