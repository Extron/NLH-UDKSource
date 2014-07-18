package 
{
	import flash.display.MovieClip;

	public class StatDetails extends InformationBoxDetails
	{
		public function StatDetails()
		{
		}
		
		public function AddStat(statData:Object)
		{
			var stat = new CharacterStat();
	
			stat.SetStat(statData.statName, statData.statValue, statData.statDefault);
			
			stat.x = 0;
			stat.y = numChildren * (32 + 4);
			
			addChild(stat);
		}
	}
}