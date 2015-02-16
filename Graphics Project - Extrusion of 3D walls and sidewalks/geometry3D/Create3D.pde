void createModel()
{
  int count = 0; //counts the number of vertices put in the Q table - equivalent to nv
  int flag = 0;
  println("nc: "+nC);
  for(int i = 0;i<nC;i++)
  {
    C1[i][4] = 0; //make visited 0 for all corners
  }
  
  int k = 0; //starting corner
  int sc= 0; //swing corner
 
 int CurCorner = k;
    if(C1[CurCorner][2]==-1)
    {
      if(C1[C1[CurCorner][1]][2]== -1)
      {
        n_loops++;
        flag = 1;
       pt P1 = P(CP1[CurCorner].x-300.0f,CP1[CurCorner].y-300.0f,0.0f);
       pt P2 = P(CP1[C1[CurCorner][1]].x-300.0f,CP1[C1[CurCorner][1]].y-300.0f,0.0f);
      Q.addPt(P1);
      Q.addPt(P2);
      count+=2; //increase count on storing each point in Q. Hence, it will be one more than the index of last point stored.
      }
      else
      {
      k = C1[CurCorner][1];
      CurCorner = k;
      }
    }
    if(flag == 0)
    {
      for(int i = k; i<nC;i++)
      {
        if(C1[i][4]==0)
        {
          k = i;
          CurCorner = k;
          if(C1[i][2] != -1)
          {
            int visited_swing = C1[i][2];
            while(C1[visited_swing][4] !=1)
            {
              visited_swing = C1[visited_swing][2];
              if(visited_swing == C1[i][2])
                break;
            }
            if(C1[visited_swing][4] == 1)
            {
              int s = visited_swing;
              pt t = P(CP1[s].x-300.0f,CP1[s].y-300.0f,0.0f);
              //println("t: "+t.x+", "+t.y+", "+t.z);
              for(int j = 0;j<count;j++)
              {
                //println("Q.G[j]: "+Q.G[j].x+", "+Q.G[j].y+", "+Q.G[j].z);
                if(Q.G[j].x == t.x && Q.G[j].y==t.y &&Q.G[j].z == t.z)
                 {
                  connections[n_loops-1][0] = j; //index of already visited vertex
              connections[n_loops-1][1] = count; //index of vertex of new loop , hence also, new starting point for the loop 
              println(n_loops+" connection:"+connections[n_loops-1][0]+" "+ connections[n_loops-1][1]);
                 break;}
              }
                            
            }
          }        
      //do
      //{
        n_loops++;
      println("number of loops: "+n_loops);
      do
      {
      pt P = P(CP1[CurCorner].x-300.0f,CP1[CurCorner].y-300.0f,0.0f);
      Q.addPt(P);
      count++; //increase count on storing each point in Q. Hence, it will be one more than the index of last point stored.
      C1[CurCorner][4] = 1;
      CurCorner = C1[CurCorner][1];      
      }while(CurCorner!=k);
      
     // CurCorner = C1[CurCorner][2];
     // while(C1[CurCorner][4] == 1)
      //{
      //  if(CurCorner == k)
      //    {k = sc; CurCorner = sc; break;}
      //  CurCorner = C1[CurCorner][2];
      //}
      //if(CurCorner!=k)
      //{
      //  k= CurCorner;
      //  connections[n_loops-1][0] = k;
      //  connections[n_loops-1][1] = count;
      //}
      //}while(k!=sc);
     }
      }
     
    }
    
    

}
