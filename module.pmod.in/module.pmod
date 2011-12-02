constant __author = "Jeff Hungerford <hungerf3@house.ofdoom.com>";
constant __version = "0.1";
constant __commit = "$Id:$";

/* 
 * The basic interface for a single instance of a daemontools managed service
 */

class Service {
  protected string service_path;

  string _GetStatus()
  {
    return Stdio.FILE(service_path+"supervise/status")->read();
  }


  mapping DecodeStatus()
  {

    Calendar.ISO.Second  _UnpackTAI64(string packed_time)
    {
      int timestamp ;
      sscanf(packed_time[0..8], "%8c", timestamp);
      return Calendar.ISO.Second(timestamp-pow(2,62))->beginning();
    };

    string status = _GetStatus();
    mapping result = ([
      "paused":status[16],
      "wanted":status[17],
      "statechange":_UnpackTAI64(status[0..8]),
      "pid":(status[12])+
      (status[13]<<8)+
      (status[14]<<16)+
      (status[15]<<24)
    ]);
    
  }

  void create(string path)
  {
    service_path = path;
  }
  
  Calendar.ISO.Second LastStateChange()
  {
    DecodeStatus()["statechange"];
  }

  int(0..1) IsRunning()
  {
    int pid = DecodeStatus()["pid"];
    if (pid)
      if (!catch {System.getpgrp(pid);})
	return 1;
    return 0;
  }

  
  void _SendCommand(string command)
  {
    Stdio.File(service_path+"/supervise/control")->write(command);
  }

  int (0..1) IsSupervised()
  {

  }
  
  void Start()
  {
    _SendCommand("u");
  }

  void Stop()
  {
    _SendCommand("d");
  }

  void Pause()
  {
    _SendCommand("p");
  }

  void Continue()
  {
    _SendCommand("c");
  }
  void RunOnce()
  {
    _SendCommand("o");
  }
  void Hangup()
  {
    _SendCommand("h");
  }
  void Alarm()
  {
    _SendCommand("a");
  }
  void Interrupt()
  {
    _SendCommand("i");
  }
  void Terminate()
  {
    _SendCommand("t");
  }
  void Kill()
  {
    _SendCommand("k");
  }
  void StopSupervisor()
  {
    _SendCommand("x");
  }
}

  
