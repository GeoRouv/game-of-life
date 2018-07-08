#include <stdio.h>
#include <stdlib.h>

int main(int argc, char* argv[])
{
  
  int dim = atoi(argv[1]);
  
  int i;
  for(i = 0; i < dim*dim; i++)
  {
    if((i % dim == 0) && (i!=0))
      putchar('\n');
     char c = getchar();
     putchar(c);
  }
  
  return 0;
}
