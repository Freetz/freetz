/*
 * ./bash_cv_ulimit_maxfds && echo 'yes' || echo 'no'
 */

main()
{
long maxfds = ulimit(4, 0L);
exit (maxfds == -1L);
}
