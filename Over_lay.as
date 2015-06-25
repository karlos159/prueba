package com.edux  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	
	public class Over_lay extends MovieClip {
		
		
		public function Over_lay() {
			trace("hello word");
			btnIzq.onClick = onClick;
			btnDer.onClick = onClick;
			btnInicio.onClick = onClick;
			btnMenu.onClick = onClick;
			btnRecursos.onClick = onClick;
			btnAyuda.onClick = onClick;
			btnTitulo.onClick = onClick;
			btnSubtitulos.onClick = onClick;
			btnPlay.onClick = onClick;
			btnMute.onClick = onClick;
			prepareBaloon();
		}
		
		private function prepareBaloon():void 
		{
			glbIzq.visible = false;
			glbDer.visible = false;
			glbInicio.visible = false;
			glbMenu.visible = false;
			glbRecursos.visible = false;
			glbAyuda.visible = false;
			glbTitulo.visible = false;
			glbSubtitulos.visible = false;
			glbPlay.visible = false;
			glbMute.visible = false;
		}
		
		private function onClick(e:MouseEvent):void 
		{
			trace("CLICK EN " + e.currentTarget.name);
			switch(e.currentTarget.name){
				case "btnIzq":
					
				break;
				case "btnDer":
					
				break;
				case "btnInicio":
					
				break;
				case "btnMenu":
					
				break;
				case "btnRecursos":
					
				break;
				case "btnAyuda":
					
				break;
				case "btnTitulo":
					
				break;
				case "btnSubtitulos":
					
				break;
				case "btnPlay":
					
				break;
				case "btnMute":
					
				break;
			}
		}
		
		
		
	}
	
}
