  <   :   k820309    l          18.0        Yjd[                                                                                                          
       src/decompose_mesh/module_partition.f90 MODULE_PARTITION                      @                              
                                                           
       NGNOD             @                                           #         @ �                                                    #A    #ID              
                                                   
               &                                                     
                                                                   &                                                      @                                                      @                                                                    &                                           #         @                                   	                    #ELMNTS 
   #NODES_COORDS    #LOAD_ELMNTS    #NSPEC    #NNODES    #NPART_1    #NPART_2    #NPART_3             
  @                               
                          p        5 r    p          5 r      5 � p        r        5 r      5 � p        r                               
  @                                                   
    p          p          5 � p        r        p          5 � p        r                               
                                                      
    p          5 � p        r        5 � p        r                                
  @                                                    
  @                                                    
  @                                                    
  @                                                    
  @                                          #         @                                                      #ELMNTS_CENTER    #ELMNTS    #NODES_COORDS    #NSPEC    #NNODES             
D                                                     
 6    p          p          5 � p        r        p          5 � p        r                               
                                                       5     p        5 r    p          5 r      5 � p        r        5 r      5 � p        r                               
                                                      
 4   p          p          5 � p        r        p          5 � p        r                                
                                                       
                                             #         @                                                      #IPART_TMP    #NEIPART_TMP    #NPART_TMP    #SUM_LOAD_TMP    #CRI_LOAD_PERM    #LOAD_ELMNTS_TMP    #ELMNTS_CENTER_TMP     #IPERM_TMP !   #NE_TMP    #REF_POINT "   #IDIR #            
D                                                      #    p          5 � p 	       r        5 � p 	       r                               
D                                                      "    p          5 � p        r        5 � p        r                                
  @                                                   
D @                                                   
 %    p          5 � p 	       r        5 � p 	       r                               
D @                                                   
 &    p          5 � p 	       r        5 � p 	       r                               
  @                                                   
     p          5 � p 	       r        5 � p 	       r                               
  @                                                    
 !   p          p          5 � p 	       r        p          5 � p 	       r                               
D @                               !                     $    p          5 � p 	       r        5 � p 	       r                                
  @                                                    
  @                               "                   
    p          p            p                                    
  @                               #           #         @                                  $                 
   #LOAD_ELMNTS_1 %   #ELMNTS_CENTER_1 '   #OLD_NUM_1 (   #NE_1 &   #IPART_0 )   #LOAD_ELMNTS_0 +   #ELMNTS_CENTER_0 ,   #OLD_NUM_0 -   #KPART_0 .   #NE_0 *            
D                                 %                    
 -    p          5 � p        r &       5 � p        r &                              
D                                 '                    
 ,    p          p          5 � p        r &       p          5 � p        r &                              
D                                 (                     +    p          5 � p        r &       5 � p        r &                               
                                  &                    
                                  )                     '   p          5 � p 
       r *       5 � p 
       r *                              
                                  +                    
 *   p          5 � p 
       r *       5 � p 
       r *                              
                                  ,                    
 )   p          p          5 � p 
       r *       p          5 � p 
       r *                              
                                  -                     (   p          5 � p 
       r *       5 � p 
       r *                               
                                  .                     
                                  *           #         @                                  /                    #CRI_LOAD_PERM 0   #ELMNTS_CENTER_TMP 2   #NE_TMP 1   #REF_POINT 3   #IDIR 4            
D                                 0                    
 0    p          5 � p        r 1       5 � p        r 1                              
                                  2                    
 /   p          p          5 � p        r 1       p          5 � p        r 1                               
                                  1                     
                                  3                   
 .   p          p            p                                    
                                  4           #         @                                  5                    #SUM_LOAD 6   #LOAD_ELMNTS 8   #IPERM_TMP 9   #NE_TMP 7            
D                                 6                    
 3    p          5 � p        r 7       5 � p        r 7                              
                                  8                    
 2   p          5 � p        r 7       5 � p        r 7                              
                                  9                     1   p          5 � p        r 7       5 � p        r 7                               
                                  7              �   A      fn#fn    �   @   J   MODULE_QSORT "   !  F   J  SHARED_PARAMETERS .   g  @       NGNOD+SHARED_INPUT_PARAMETERS $   �  W       QSORTC+MODULE_QSORT &   �  �   a   QSORTC%A+MODULE_QSORT '   �  �   a   QSORTC%ID+MODULE_QSORT      @       NE    V  �       IPART    �  �       DECOMPOSE_MESH &   �  �   a   DECOMPOSE_MESH%ELMNTS ,   �  �   a   DECOMPOSE_MESH%NODES_COORDS +   _  �   a   DECOMPOSE_MESH%LOAD_ELMNTS %     @   a   DECOMPOSE_MESH%NSPEC &   S  @   a   DECOMPOSE_MESH%NNODES '   �  @   a   DECOMPOSE_MESH%NPART_1 '   �  @   a   DECOMPOSE_MESH%NPART_2 '     @   a   DECOMPOSE_MESH%NPART_3 &   S  �       COMPUTE_ELMNTS_CENTER 4   �  �   a   COMPUTE_ELMNTS_CENTER%ELMNTS_CENTER -   �	  �   a   COMPUTE_ELMNTS_CENTER%ELMNTS 3   �
  �   a   COMPUTE_ELMNTS_CENTER%NODES_COORDS ,     @   a   COMPUTE_ELMNTS_CENTER%NSPEC -   �  @   a   COMPUTE_ELMNTS_CENTER%NNODES "   �  �       COMPUTE_PARTITION ,   �  �   a   COMPUTE_PARTITION%IPART_TMP .   �  �   a   COMPUTE_PARTITION%NEIPART_TMP ,   c  @   a   COMPUTE_PARTITION%NPART_TMP /   �  �   a   COMPUTE_PARTITION%SUM_LOAD_TMP 0   W  �   a   COMPUTE_PARTITION%CRI_LOAD_PERM 2     �   a   COMPUTE_PARTITION%LOAD_ELMNTS_TMP 4   �  �   a   COMPUTE_PARTITION%ELMNTS_CENTER_TMP ,   �  �   a   COMPUTE_PARTITION%IPERM_TMP )   G  @   a   COMPUTE_PARTITION%NE_TMP ,   �  �   a   COMPUTE_PARTITION%REF_POINT '     @   a   COMPUTE_PARTITION%IDIR "   [  �       EXTRACT_PARTITION 0   ?  �   a   EXTRACT_PARTITION%LOAD_ELMNTS_1 2   �  �   a   EXTRACT_PARTITION%ELMNTS_CENTER_1 ,   �  �   a   EXTRACT_PARTITION%OLD_NUM_1 '   {  @   a   EXTRACT_PARTITION%NE_1 *   �  �   a   EXTRACT_PARTITION%IPART_0 0   o  �   a   EXTRACT_PARTITION%LOAD_ELMNTS_0 2   #  �   a   EXTRACT_PARTITION%ELMNTS_CENTER_0 ,   �  �   a   EXTRACT_PARTITION%OLD_NUM_0 *   �  @   a   EXTRACT_PARTITION%KPART_0 '   �  @   a   EXTRACT_PARTITION%NE_0 !   +  �       COMPUTE_CRITERIA /   �  �   a   COMPUTE_CRITERIA%CRI_LOAD_PERM 3   v  �   a   COMPUTE_CRITERIA%ELMNTS_CENTER_TMP (   J  @   a   COMPUTE_CRITERIA%NE_TMP +   �  �   a   COMPUTE_CRITERIA%REF_POINT &     @   a   COMPUTE_CRITERIA%IDIR !   ^  �       COMPUTE_SUM_LOAD *   �  �   a   COMPUTE_SUM_LOAD%SUM_LOAD -   �  �   a   COMPUTE_SUM_LOAD%LOAD_ELMNTS +   H  �   a   COMPUTE_SUM_LOAD%IPERM_TMP (   �  @   a   COMPUTE_SUM_LOAD%NE_TMP 