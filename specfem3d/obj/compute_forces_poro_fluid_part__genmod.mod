  k-  3   k820309    l          18.0        -jd[                                                                                                          
       src/specfem3D/compute_forces_poro_fluid_part.f90 COMPUTE_FORCES_PORO_FLUID_PART #         @                                       	            1   #IPHASE    #NSPEC_AB    #NGLOB_AB    #DISPLW_POROELASTIC    #ACCELW_POROELASTIC    #VELOCW_POROELASTIC    #DISPLS_POROELASTIC    #XIX 	   #XIY 
   #XIZ    #ETAX    #ETAY    #ETAZ    #GAMMAX    #GAMMAY    #GAMMAZ    #HPRIME_XX    #HPRIME_YY    #HPRIME_ZZ    #HPRIMEWGLL_XX    #HPRIMEWGLL_YY    #HPRIMEWGLL_ZZ    #WGLLWGLL_XY    #WGLLWGLL_XZ    #WGLLWGLL_YZ    #WXGLL    #WYGLL    #WZGLL    #KAPPAARRAYSTORE    #RHOARRAYSTORE    #MUSTORE     #ETASTORE !   #PERMSTORE "   #PHISTORE #   #TORTSTORE $   #JACOBIAN %   #IBOOL &   #EPSILONWDEV_XX '   #EPSILONWDEV_YY )   #EPSILONWDEV_XY *   #EPSILONWDEV_XZ +   #EPSILONWDEV_YZ ,   #EPSILONW_TRACE_OVER_3 -   #SIMULATION_TYPE .   #NSPEC_ADJOINT (   #NUM_PHASE_ISPEC_POROELASTIC /   #NSPEC_INNER_POROELASTIC 0   #NSPEC_OUTER_POROELASTIC 1   #PHASE_ISPEC_INNER_POROELASTIC 2                                                                                                                                                                                                                           
 =    p          p          5 � p        r        p          5 � p        r                               D                                                  
 >    p          p          5 � p        r        p          5 � p        r                                                                                 
 ?    p          p          5 � p        r        p          5 � p        r                                                                                 
 @    p          p          5 � p        r        p          5 � p        r                                                             	                    
 A    p �         p          p          p          5 � p        r        p          p          p          5 � p        r                                                             
                    
 B    p �         p          p          p          5 � p        r        p          p          p          5 � p        r                                                                                 
 C    p �         p          p          p          5 � p        r        p          p          p          5 � p        r                                                                                 
 D    p �         p          p          p          5 � p        r        p          p          p          5 � p        r                                                                                 
 E    p �         p          p          p          5 � p        r        p          p          p          5 � p        r                                                                                 
 F    p �         p          p          p          5 � p        r        p          p          p          5 � p        r                                                                                 
 G    p �         p          p          p          5 � p        r        p          p          p          5 � p        r                                                                                 
 H    p �         p          p          p          5 � p        r        p          p          p          5 � p        r                                                                                 
 I    p �         p          p          p          5 � p        r        p          p          p          5 � p        r                                                                                 
 J    p          p          p            p          p                                                                                     
 K    p          p          p            p          p                                                                                     
 L    p          p          p            p          p                                                                                     
 M    p          p          p            p          p                                                                                     
 N    p          p          p            p          p                                                                                     
 O    p          p          p            p          p                                                                                     
 P    p          p          p            p          p                                                                                     
 Q    p          p          p            p          p                                                                                     
 R    p          p          p            p          p                                                                                      
 S    p          p            p                                                                                      
 T    p          p            p                                                                                      
 U    p          p            p                                                                                     
 V    p �        p          p          p          p          5 � p        r        p          p          p          p          5 � p        r                                                                                 
 W    p 9        p          p          p          p          5 � p        r        p          p          p          p          5 � p        r                                                                                  
 X    p �         p          p          p          5 � p        r        p          p          p          5 � p        r                                                             !                    
 Y    p �         p          p          p          5 � p        r        p          p          p          5 � p        r                                                             "                    
 Z    p �        p          p          p          p          5 � p        r        p          p          p          p          5 � p        r                                                             #                    
 [    p �         p          p          p          5 � p        r        p          p          p          5 � p        r                                                             $                    
 \    p �         p          p          p          5 � p        r        p          p          p          5 � p        r                                                             %                    
 ]    p �         p          p          p          5 � p        r        p          p          p          5 � p        r                                                              &                     ^    p �         p          p          p          5 � p        r        p          p          p          5 � p        r                               D                              '                    
 _    p �         p          p          p          5 � p -       r (       p          p          p          5 � p -       r (                              D                              )                    
 `    p �         p          p          p          5 � p -       r (       p          p          p          5 � p -       r (                              D                              *                    
 a    p �         p          p          p          5 � p -       r (       p          p          p          5 � p -       r (                              D                              +                    
 b    p �         p          p          p          5 � p -       r (       p          p          p          5 � p -       r (                              D                              ,                    
 c    p �         p          p          p          5 � p -       r (       p          p          p          5 � p -       r (                              D                              -                    
 d    p �         p          p          p          5 � p -       r (       p          p          p          5 � p -       r (                                                              .                                                    (                                                    /                                                     0                                                     1                                                    2                     e      p        5 � p .       r /   p          5 � p .       r /     p            5 � p .       r /     p                             �   X      fn#fn /   �   �  `   COMPUTE_FORCES_PORO_FLUID_PART    �  @   a   IPHASE    �  @   a   NSPEC_AB      @   a   NGLOB_AB #   L  �   a   DISPLW_POROELASTIC #   "  �   a   ACCELW_POROELASTIC #   �  �   a   VELOCW_POROELASTIC #   �  �   a   DISPLS_POROELASTIC    �    a   XIX    �	    a   XIY    �
    a   XIZ    �    a   ETAX    �    a   ETAY        a   ETAZ    (    a   GAMMAX    >    a   GAMMAY    T    a   GAMMAZ    j  �   a   HPRIME_XX      �   a   HPRIME_YY    �  �   a   HPRIME_ZZ    �  �   a   HPRIMEWGLL_XX    :  �   a   HPRIMEWGLL_YY    �  �   a   HPRIMEWGLL_ZZ    �  �   a   WGLLWGLL_XY    V  �   a   WGLLWGLL_XZ    
  �   a   WGLLWGLL_YZ    �  �   a   WXGLL    R  �   a   WYGLL    �  �   a   WZGLL     z  6  a   KAPPAARRAYSTORE    �  6  a   RHOARRAYSTORE    �    a   MUSTORE    �    a   ETASTORE      6  a   PERMSTORE    H     a   PHISTORE    ^!    a   TORTSTORE    t"    a   JACOBIAN    �#    a   IBOOL    �$    a   EPSILONWDEV_XX    �%    a   EPSILONWDEV_YY    �&    a   EPSILONWDEV_XY    �'    a   EPSILONWDEV_XZ    �(    a   EPSILONWDEV_YZ &   *    a   EPSILONW_TRACE_OVER_3     $+  @   a   SIMULATION_TYPE    d+  @   a   NSPEC_ADJOINT ,   �+  @   a   NUM_PHASE_ISPEC_POROELASTIC (   �+  @   a   NSPEC_INNER_POROELASTIC (   $,  @   a   NSPEC_OUTER_POROELASTIC .   d,    a   PHASE_ISPEC_INNER_POROELASTIC 