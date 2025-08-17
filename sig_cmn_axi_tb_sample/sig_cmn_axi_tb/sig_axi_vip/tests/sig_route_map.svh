/*
   ######################################################################################
 *      Signature IP Corporation Confidential and Proprietary Information               #
 *      Copyright 2022 Signature IP Corporation                                         #
 *      All Rights Reserved.                                                            #
 *      This is UNPUBLISHED PROPRIETARY SOURCE CODE OF Signature IP Corporation         #
 *      The copyright notice above does not evidence any actual or intended publication #
 *      of such source code.                                                            #
 * ######################################################################################

*/
/*
 Masters are number from 0, counting from cluster0 and slot0
 */
typedef int IntArr[];
typedef bit[`MAX_ADDR_WIDTH-1:0] AddrArr[];

/*
 Routing map indicates route from each slave to masters
 4x4, complementatry pattern
 */
/*
IntArr routingMap_comp[int] = '{0:'{30, 31},
				1:'{30, 31},
				2:'{28, 29},
				3:'{29, 29},
				...
				30:'{0, 1},
				31:'{0, 1}
				};

IntArr routingMap_bitRev[int] = '{...
				  };

IntArr routingMap_shuffle[int] = '{...
				  };

IntArr routingMap_butterfly[int] = '{...
				  };

....

*/
AddrArr masterAddrMap[int] = '{0:'{
				   {32'ha_aaaa},
				   {32'ha_bbbb}
				   },
			       1:'{
				   {32'h1a_aaaa},
				   {32'h1a_bbbb}
				   }
			       };
/*
string slaveInjRate[int] = '{0: "constant#10",
			     1: "uni_dist#10#80",
			     ...
			     };
*/

