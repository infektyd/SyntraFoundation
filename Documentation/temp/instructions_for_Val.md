➜  syntrachat git:(main) ✗ swift build  
[1/1] Planning build
Building for debugging...
/Users/hansaxelsson/SyntraFoundation/SyntraChat/SettingsPanel.swift:14:41: error: value of type 'SyntraConfig' has no member 'enableTwoPassLoop'
12 |         self.useAdaptiveFusion    = cfg.useAdaptiveFusion ?? false
13 |         self.useAdaptiveWeighting = cfg.useAdaptiveWeighting ?? false
14 |         self.enableTwoPassLoop    = cfg.enableTwoPassLoop ?? false
   |                                         `- error: value of type 'SyntraConfig' has no member 'enableTwoPassLoop'
15 |     }
16 | 

/Users/hansaxelsson/SyntraFoundation/SyntraChat/SettingsPanel.swift:21:13: error: value of type 'SyntraConfig' has no member 'enableTwoPassLoop'
19 |         cfg.useAdaptiveFusion    = useAdaptiveFusion
20 |         cfg.useAdaptiveWeighting = useAdaptiveWeighting
21 |         cfg.enableTwoPassLoop    = enableTwoPassLoop
   |             `- error: value of type 'SyntraConfig' has no member 'enableTwoPassLoop'
22 |         if let data = try? JSONEncoder().encode(cfg) {
23 |             let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
[3/6] Compiling SyntraChat SettingsPanel.swift
➜  syntrachat git:(main) ✗ 
