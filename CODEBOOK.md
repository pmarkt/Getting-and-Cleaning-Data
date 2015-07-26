

This second programming assignment creates an R function that is able 
to cache potentially time-consuming computations. If the contents of a 
vector are not changing, it may make sense to cache the value of the 
inverse so that when we need it again, it can be looked up in the cache
rather than recomputed. This Programming Assignment takes advantage of 
the scoping rules of the R language and how they can be manipulated 
to preserve state inside of an R object.

