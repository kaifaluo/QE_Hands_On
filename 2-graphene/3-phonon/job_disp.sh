cat > q2r.in << !

&input
 prefix = 'graphene'
 fildyn = 'graphene.dyn'
 zasr   = 'zero-dim'
 flfrc  = 'graphene.fc'
/
!

## ==
cat > matdyn.in <<!

&INPUT
  asr = 'simple'
  flfrc = 'graphene.fc'
  flfrq = 'graphene.freq'
  q_in_band_form = .true.
 /

 5
0.0  0.0  0.0   40
1/3  1/3  0.0   40
0.5  0.0  0.0   40
0.0  0.0  0.0   40
0.0  0.0  0.5   40
!


## ==
cat > plotband.in<<!

graphene.freq
0 5000
freq.plot
freq.ps
0.0
100.0 0.0
!
